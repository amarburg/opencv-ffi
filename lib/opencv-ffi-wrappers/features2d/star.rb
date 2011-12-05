require 'opencv-ffi/features2d'
require 'opencv-ffi-wrappers/core'
require 'opencv-ffi-wrappers/enumerable'
require 'opencv-ffi-wrappers/vectors'
require 'opencv-ffi-ext/vector_math'

module CVFFI
  

  module STAR

    class Result 
      attr_accessor :kp
      def initialize( kp )
        @kp = CVFFI::CvStarKeypoint.new(kp)
      end

      def pt; @kp.pt; end
      def x;  pt.x; end
      def y;  pt.y; end

      def size; @kp.size; end
      def response; @kp.response; end

      def to_vector( homogeneous = true )
        homogeneous ?  Vector.[]( x, y, 1 ) : Vector.[](x,y)
      end
      
      def to_Point
        pt.to_Point
      end
   end

    class ResultsArray
      include Enumerable

      attr_accessor :kp

      def initialize( kp )
        @kp = Sequence.new(kp)
        @results = Array.new( @kp.length )
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

      def mark_on_image( img, opts )
        each { |r|
          CVFFI::draw_circle( img, r.kp.pt, opts )
        }
      end
    end

    class Params

      DEFAULTS = { maxSize: 45,
                   responseThreshold: 30,
                   lineThresholdProjected: 10,
                   lineThresholdBinarized: 8,
                   suppressNonmaxSize: 5 }

      def initialize( opts = {} )

        @params = {}
        DEFAULTS.each_key { |k|
          @params[k] = (opts[k] or DEFAULTS[k])
        }
      end

      def to_CvStarDetectorParams
        par = @params
        par.delete_if { |k,v| DEFAULTS.keys.include? k == false }
        p par
        CVFFI::CvStarDetectorParams.new( par )
      end

      def to_hash
        @params
      end
    end

    def self.detect( img, params )
      params = params.to_CvStarDetectorParams unless  params.is_a?( CvStarDetectorParams )
      raise ArgumentError unless params.is_a?( CvStarDetectorParams ) 

      img = img.to_IplImage.ensure_greyscale
      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      keypoints = CVFFI::CvSeq.new CVFFI::cvGetStarKeypoints( img, mem_storage, params )
      ResultsArray.new( keypoints )
    end
  end
end
