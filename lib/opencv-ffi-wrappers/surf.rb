
require 'opencv-ffi/features2d'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/misc_draw'
require 'opencv-ffi-wrappers/sequence'

module CVFFI
  

  module SURF

 #   class Params 
#
  #  end

    class Result 
      attr_accessor :kp, :desc
      def initialize( kp, desc )
        @kp = CVFFI::CvSURFPoint.new(kp)
        @desc = desc
      end

      def pt; @kp.pt; end

   end

    class ResultsArray
      include Enumerable

      attr_accessor :kp, :desc, :pool

      def initialize( kp, desc, pool )
        @kp = Sequence.new(kp)
        @desc = Sequence.new(desc)
        @pool = pool

        raise RuntimeError "SURF Keypoint and descriptor sequences different length (#{@kp.size} != #{@desc.size})" unless (@kp.size == @desc.size)

        destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @pool ); cvReleaseMemStorage( poolPtr ) }
        ObjectSpace.define_finalizer( self, destructor )
      end

      def each
        @kp.each_with_index { |kp,i| 
          r = Result.new( kp, @desc[i]  )
          yield r 
        }
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
