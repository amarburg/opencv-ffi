
require 'opencv-ffi/features2d/mser'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/misc_draw'
require 'opencv-ffi-wrappers/core/sequence'
require 'opencv-ffi-wrappers/vectors'

require 'opencv-ffi-wrappers/misc/params'

module CVFFI

  class CvMSERParams
    def to_CvMSERParams
      self
    end
  end

  module MSER

    class Result 
#      attr_accessor :kp, :desc
#      def initialize( kp, desc )
#        @kp = CVFFI::CvSURFPoint.new(kp)
#        @desc = desc
#      end

#      def pt; @kp.pt; end
#      def x;  pt.x; end
#      def y;  pt.y; end

#      def distance_to( q )
        #  Here's the pure-Ruby way to do it
      #  @desc.inject_with_index(0.0) { |x,d,i| x + (d-q.desc.d[i])**2  }
        
#        CVFFI::VectorMath::L2distance( @desc, q.desc )
#      end

#      def to_vector
#        Vector.[]( x, y, 1 )
#      end
      
#      def to_Point
#        pt.to_Point
#      end
   end

    class ResultsArray
      include Enumerable

      attr_accessor :kp, :pool

      def initialize( kp, pool )
        @kp = Sequence.new(kp)
        @pool = pool

        @results = Array.new( @kp.length )

        destructor = Proc.new { poolPtr = FFI::MemoryPointer.new :pointer; poolPtr.putPointer( 0, @pool ); cvReleaseMemStorage( poolPtr ) }
        ObjectSpace.define_finalizer( self, destructor )
      end

      def result(i)
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

      def mark_on_image( img, opts )
        each { |r|
          CVFFI::draw_circle( img, r.kp.pt, opts )
        }
      end
    end

    class Params < CVFFI::Params

      param :delta, 5
      param :minArea, 60
      param :maxArea, 14400
      param :maxVariation, 0.25
      param :minDiversity, 0.2
      param :maxEvolution, 200
      param :areaThreshold, 1.01
      param :minMargin, 0.003
      param :edgeBlurSize, 5

      def to_CvMSERParams
        par = @params
        par.delete_if { |k,v| defaults.keys.include? k == false }
        CVFFI::CvMSERParams.new( par )
      end
    end

    def self.detect( img, params )

      params = params.to_CvMSERParams
      raise ArgumentError unless params.is_a?( CvMSERParams ) 

      img = img.to_IplImage

      contour_ptr = FFI::MemoryPointer.new :pointer
      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      CVFFI::cvExtractMSER( img, nil, contour_ptr, mem_storage, params )

      contours = CVFFI::CvSeq.new( contour_ptr.read_pointer() )
      ResultsArray.new( contours, mem_storage )

    end
  end
end
