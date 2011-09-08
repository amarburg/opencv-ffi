
require 'opencv-ffi/features2d'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/misc_draw'
require 'opencv-ffi-wrappers/sequence'
require 'opencv-ffi-wrappers/enumerable'

module CVFFI
  

  module SURF

 #   class Params 
#
  #  end

    class FloatArrayCommon < NiceFFI::Struct
      include Enumerable

      def each
        size.times { |i|
          yield d[i]
        }
      end
    end

    class Float64 < FloatArrayCommon
      SIZE = 64
      layout :d, [ :float, SIZE ]

      def size; SIZE; end
    end

     class Float128 < FloatArrayCommon
      SIZE = 128
      layout :d, [ :float, SIZE ]

      def size; SIZE; end
    end
 
    class Result 
      attr_accessor :kp, :desc
      def initialize( kp, desc )
        @kp = CVFFI::CvSURFPoint.new(kp)
        @desc = desc
      end

      def pt; @kp.pt; end

      def distance_to( q )
        # Hardcode 64-bit descriptors for now
        # Could do with inject?
        @desc.inject_with_index(0.0) { |x,d,i| x + (d-q.desc.d[i])**2  }
        #x = 0.0
        #@desc.size.times { |i| x += (@desc.d[i]-q.desc.d[i])**2 }
        #x 
      end
   end

    class ResultsArray
      include Enumerable

      attr_accessor :kp, :desc, :pool
      attr_accessor :desc_type

      def initialize( kp, desc, pool, desc_type = Float64 )
        @kp = Sequence.new(kp)
        @desc = Sequence.new(desc)
        @pool = pool
        @desc_type = desc_type

        raise RuntimeError "SURF Keypoint and descriptor sequences different length (#{@kp.size} != #{@desc.size})" unless (@kp.size == @desc.size)

        destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @pool ); cvReleaseMemStorage( poolPtr ) }
        ObjectSpace.define_finalizer( self, destructor )
      end

      def each
        @kp.each_with_index { |kp,i| 
          r = Result.new( kp, @desc_type.new( @desc[i] )  )
          yield r 
        }
      end

      def [](i)
        Result.new( @kp[i], @desc_type.new(@desc[i]) )
      end

      def size
        @kp.size
      end
      alias :length :size

      def mark_on_image( img, opts )
        each { |r|
          CVFFI::draw_circle( img, r.kp.pt, opts )
        }
      end
    end

    def self.Detect( img, params )

      raise ArgumentError unless params.is_a?( CvSURFParams ) || params.is_a?( Params )

      img = CVFFI::IplImage.new img.to_IplImage

      if img.nChannels == 3
        greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( :height => img.height,
                                                           :width => img.width ),
                                                           :IPL_DEPTH_8U, 1 )
        CVFFI::cvCvtColor( img, greyImg, :CV_RGB2GRAY )
      else
        greyImg = img
      end

      kp_ptr = FFI::MemoryPointer.new :pointer
      desc_ptr = FFI::MemoryPointer.new :pointer

      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      CVFFI::cvExtractSURF( greyImg, nil, kp_ptr, desc_ptr, mem_storage, params, :false )

      keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )
      descriptors = CVFFI::CvSeq.new( desc_ptr.read_pointer() )

      ResultsArray.new( keypoints, descriptors, mem_storage )
    end
  end
end
