
require 'nice-ffi'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

module CVFFI

  module SIFT
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    class CvSIFTParams < NiceFFI::Struct
      layout :octaves, :int,
        :intervals, :int,
        :threshold, :double,
        :edgeThreshold, :double,
        :magnification, :double
    end

    module SiftKeypointWithDescriptor
      attr_accessor :descriptor
    end

    class SiftKeypoint < NiceFFI::Struct
      include SiftKeypointWithDescriptor

      layout :x, :float,
        :y, :float,
        :featureSize, :float,
        :angle, :float,
        :response, :float,
        :octave, :int
    end


    class Keypoints
      include Enumerable

      attr_reader :kps
      attr_reader :desc

      def initialize( k, mem_storage = nil, descriptors = nil)
        if k.is_a? CvSeq
          @kps = Sequence.new( k )
          @results = Array.new( k.size )
          @mem_storage = mem_storage

          destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @mem_storage ); cvReleaseMemStorage( poolPtr ) }
          ObjectSpace.define_finalizer( self, destructor )
        else
          @kps = nil
          @results = k
        end

        @desc = descriptors if descriptors
      end

      def size
        @results.size
      end
      alias :length :size

      def each
        size.times { |i|
          yield at(i)
        }
      end

      def [](i)
        raise "Request for result out of bounds" if (i < 0 or i >= size)
        unless @results[i]
          @results[i] = SiftKeypoint.new( @kps[i] )
          if @desc
            @results[i].descriptor =  @desc[i]
          end
        end
        @results[i]
      end
      alias :at :[]

      def to_a
        ary = []
        # Would work better with map_with_index
        each_with_index { |kp,i|
          a = [ kp.x, kp.y, kp.size, kp.angle, kp.response, kp.octave ]
           a << @desc[i].to_a if @desc
          ary << a
        }
        ary
      end

      def self.from_a( a )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array

        descriptors = []
        kps = a.map { |a|
          kp = SiftKeypoint.new( a[0..6] )
          if a[7]
            ## Extract descriptors as well
            kp.descriptors << a[7]
          end
          kp
        }

        if descriptors.length > 0
          Keypoints.new( kps, nil, descriptors )
        else
          Keypoints.new( kps )
        end
      end
    end


    class Params < CVFFI::Params
      param :octaves, 4
      param :intervals, 5 
      param :threshold, 0.04
      param :edgeThreshold, 10.0 
      param :magnification, 3.0

      def to_CvSIFTParams
        CvSIFTParams.new( octaves: octaves, 
                         intervals: intervals,
                         threshold: threshold,
                         edgeThreshold: edgeThreshold,
                         magnification: magnification )
      end

    end

    attach_function :cvSIFTDetect, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void
    attach_function :cvSIFTDetectDescribe, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], CvMat.typed_pointer

    def self.detect( image, params )
      params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )

      kp_ptr = FFI::MemoryPointer.new :pointer
      storage = CVFFI::cvCreateMemStorage( 0 )
      image = image.ensure_greyscale

      cvSIFTDetect( image, nil, kp_ptr, storage, params )

      keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )

      Keypoints.new( keypoints, storage )
    end

    def self.detect_describe( image, params )
      params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )

      # I believe this is re-shaped by the function
      descriptors = CVFFI::CvMat.new( CVFFI::cvCreateMat( 1,1, :CV_32F ) )
      kp_ptr = FFI::MemoryPointer.new :pointer
      storage = CVFFI::cvCreateMemStorage( 0 )
      image = image.ensure_greyscale

      descriptors = CvMat.new( cvSIFTDetectDescribe( image, nil, kp_ptr, storage, params ))

      keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )

      descs = descriptors.to_Matrix.row_vectors

      Keypoints.new( keypoints, storage, descs )
    end

  end
end
