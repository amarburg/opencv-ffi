
require 'nice-ffi'

require 'opencv-ffi-wrappers/features2d/surf'

module CVFFI
  module OpenSURF
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../../ext/opensurf/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi_opensurf", pathset)

    class OpenSURFParams < NiceFFI::Struct
      layout :upright, :char,
             :octaves, :int,
             :intervals, :int,
             :init_sample, :int,
             :thres, :float 
    end

    class OpenSURFPoint < NiceFFI::Struct
      layout :pt, CvPoint,
             :scale, :float,
             :orientation, :float,
             :laplacian, :int,
             :descriptor, [ :float, 64 ]
    end


    # CvSeq *opensurfDet( IplImage *img,
    #                   CvMemStorage *storage,
    #                   CvSURFParams params )
    attach_function :openSurfDetect, [ :pointer, :pointer, OpenSURFParams.by_value ], CvSeq.typed_pointer 
    attach_function :openSurfDescribe, [ :pointer, :pointer, OpenSURFParams.by_value ], CvSeq.typed_pointer 
    attach_function :createOpenSURFPointSequence, [:pointer ], CvSeq.typed_pointer

    class Result
      attr_accessor :kp
      def initialize( kp )
         @kp = CVFFI::OpenSURF::OpenSURFPoint.new(kp)
      end

      def pt; @kp.pt; end
      def x;  pt.x; end
      def y;  pt.y; end

      def scale; @kp.scale; end
      def laplacian; @kp.laplacian; end
      def orientation; @kp.orientation; end
      def descriptor; @kp.descriptor; end

      def distance_to(b)
        CVFFI::VectorMath::L2distance( @kp.descriptor, b.descriptor, 64 )
      end

      def to_vector
        Vector.[]( x, y, 1 )
      end
      
      def to_Point
        pt.to_Point
      end

      def packed_descriptor
        [@kp.descriptor.to_a.pack('e64')].pack('m0')
      end
   end

    class ResultArray
      include Enumerable

      attr_reader :kp, :pool

      def initialize( kp, pool )
        @kp = Sequence.new(kp)
        @pool = pool
        @results = Array.new( @kp.length )

        destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer 
                                poolPtr.putPointer( 0, @pool ) 
                                cvReleaseMemStorage( poolPtr ) }
        ObjectSpace.define_finalizer( self, destructor )
      end

      def reset( kp )
        @kp = Sequence.new(kp)
        @pool = kp.storage
        @results = Array.new( @kp.length )
        self
      end

      def result(i)
        @results[i] ||= Result.new( @kp[i] )
      end

      def each
        @results.each_index { |i| 
          yield result(i) 
        }
      end

      def [](i)
        result(i)
      end

      def size
        @kp.size
      end
      alias :length :size

      def to_CvSeq
        @kp.seq
      end

      def mark_on_image( img, opts )
        each { |r|
          CVFFI::draw_circle( img, r.kp.pt, opts )
        }
      end

      def to_a
        Array.new( size ) { |i|
          r = result(i)
          [ r.x, r.y, r.scale, r.orientation, r.laplacian, r.packed_descriptor ]
          }
      end

      def self.from_a( a )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array

        pool = CVFFI::cvCreateMemStorage(0)
        cvseq = CVFFI::OpenSURF::createOpenSURFPointSequence( pool )
        seq = Sequence.new cvseq
        
        a.each { |r|
          raise "Hm, not what I expected" unless r.length == 6
          point = CVFFI::OpenSURF::OpenSURFPoint.new( '' )
          # Hm, the embedded CvPoint buggers up initialization by hash
          point.scale = r[2]
          point.orientation = r[3]
          point.laplacian = r[4]
          d = r[5].unpack('m')[0].unpack('e64')

          d.each_with_index { |d,i| point.descriptor[i] = d }

          # r[5].unpack('e64')
          point.pt.x = r[0]
          point.pt.y = r[1]
          seq.push( point )
        }


        ra = ResultArray.new( cvseq, pool )
      end

    end

    class Params
      DEFAULTS = { upright: 0,
                   octaves: 5,
                   intervals: 4,
                   thres: 0.0004,
                   init_sample: 2 }

      def initialize( opts = {} )
        @params = {}
        DEFAULTS.keys.each { |k|
          @params[k] = opts[k] || DEFAULTS[k]
        }
      end

      def to_OpenSurfParams
        OpenSURFParams.new( @params )
      end

      def to_hash
        @params
      end
    end


    # Detection sets x,y,scale, laplacian
    def self.detect( img, params )
      params = params.to_OpenSurfParams unless params.is_a?( OpenSURFParams ) 
      raise ArgumentError unless params.is_a?( OpenSURFParams ) 

      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      img = img.ensure_greyscale
      kp = CVFFI::CvSeq.new openSurfDetect( img, mem_storage, params )

      ResultArray.new( kp, mem_storage )
    end

    # Descriptor takes x,y, scale.  Apparently not laplcian
    # Sets orientation, descriptor
    def self.describe( img, points, params )
      params = params.to_OpenSurfParams unless params.is_a?( OpenSURFParams ) 
      raise ArgumentError unless params.is_a?( OpenSURFParams ) 

      img = img.ensure_greyscale

      puts "Extracting #{points.length} features"

      kp = points.to_CvSeq

      openSurfDescribe( img, kp, params )

      points.reset(kp)
      points
    end


  end
end
