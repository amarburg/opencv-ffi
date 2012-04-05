
require 'nice-ffi'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

module CVFFI

  module HarrisLaplace 
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    class CvHarrisParams < NiceFFI::Struct
      layout :octaves, :int,
        :corn_thresh, :float,
        :dog_thresh, :float,
        :max_corners, :int,
        :num_layers, :int
    end

    class Keypoint < NiceFFI::Struct
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
          @results = Array.new( @kps.size )
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
          @results[i] = Keypoint.new( @kps[i] )
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
      param :octaves, 6
      param :corn_thresh, 0.01
      param :dog_thresh, 0.01
      param :max_corners, 5000
      param :num_layers, 4

      def to_CvHarrisParams
        CvHarrisParams.new( @params  )
      end

    end

    attach_function :cvHarrisLaplaceDetector, [:pointer, :pointer, CvHarrisParams.by_value ], CvSeq.typed_pointer

    def self.detect( image, params )
      params = params.to_CvHarrisParams unless params.is_a?( CvHarrisParams )

      kp_ptr = FFI::MemoryPointer.new :pointer
      storage = CVFFI::cvCreateMemStorage( 0 )
      
      image = image.ensure_greyscale

      seq_ptr = cvHarrisLaplaceDetector( image, storage, params )

      keypoints = CVFFI::CvSeq.new( seq_ptr )
      puts "Returned #{keypoints.total} keypoints"

      Keypoints.new( keypoints, storage )
    end


  end
end
