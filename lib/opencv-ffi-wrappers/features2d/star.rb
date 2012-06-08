require 'opencv-ffi/features2d'
require 'opencv-ffi-wrappers/misc/params'
require 'opencv-ffi-wrappers/core'
require 'opencv-ffi-wrappers/vectors'

module CVFFI

  # Monkey patch some functions into CvStarKeypoint
  class CvStarKeypoint

    def x; pt.x; end
    def y; pt.y; end

    def self.keys
      [:x, :y, :size, :response]
    end

    def keys; self.class.keys; end

    def to_a
      keys.map { |k| send k }
    end

    def self.from_a a
      raise "Not enough elements in array to unserialize a STAR keypoint (#{a.length} != keys.length)" unless a.length == keys.length

      # Slightly awkward because of the embedded CvPoint
      kp = CvStarKeypoint.new
      kp.pt.x = a.shift
      kp.pt.y = a.shift
      kp.size = a.shift
      kp.response = a.shift
      kp
    end

    def to_vector( homogeneous = true )
      homogeneous ?  Vector.[]( x, y, 1 ) : Vector.[](x,y)
    end
    alias :to_Vector :to_vector

    def to_Point
      Point.new( x,y )
    end

    def to_CvPoint
      CvPoint.new( x,y )
    end

    def ==(b)
      keys.inject( true ) { |m,key|
        m and ( (send key) == (b.send key) )
      }
    end

  end

  module STAR

    #    class Result 
    #      attr_accessor :kp
    #      def initialize( kp )
    #        @kp = CVFFI::CvStarKeypoint.new(kp)
    #      end
    #
    #      def pt; @kp.pt; end
    #      def x;  pt.x; end
    #      def y;  pt.y; end
    #
    #      def size; @kp.size; end
    #      def response; @kp.response; end
    #
    #      def to_vector( homogeneous = true )
    #        homogeneous ?  Vector.[]( x, y, 1 ) : Vector.[](x,y)
    #      end
    #      alias :to_Vector :to_vector
    #      
    #      def to_Point
    #        pt.to_Point
    #      end
    #
    #      def to_CvPoint
    #        pt.to_CvPoint
    #      end
    #
    #   end

    class Results < SequenceArray
      sequence_class  CvStarKeypoint
      #
      #      attr_accessor :kp
      #
      #      def initialize( kp )
      #        @kp = Sequence.new(kp)
      #        @results = Array.new( @kp.length )
      #      end
      #
      #      def result(i)
      #        @results[i] ||= Result.new( @kp[i] )
      #      end
      #
      #      def each
      #        @results.each_index { |i| 
      #          yield result(i) 
      #        }
      #      end
      #
      #      def [](i)
      #        result(i)
      #      end
      #
      #      def size
      #        @kp.size
      #      end
      #      alias :length :size
      #
      def mark_on_image( img, opts )
        each { |r|
          CVFFI::draw_circle( img, r.pt, opts )
        }
      end
    end

    class Params  < CVFFI::Params

      param :maxSize, 45
      param :responseThreshold, 30
      param :lineThresholdProjected, 10
      param :lineThresholdBinarized, 8
      param :suppressNonmaxSize, 5

#      DEFAULTS = { maxSize: 45,
#        responseThreshold: 30,
#        lineThresholdProjected: 10,
#        lineThresholdBinarized: 8,
#        suppressNonmaxSize: 5 }
#
#      def initialize( opts = {} )
#
#        @params = {}
#        DEFAULTS.each_key { |k|
#          @params[k] = (opts[k] or DEFAULTS[k])
#        }
#      end

      def to_CvStarDetectorParams
        CVFFI::CvStarDetectorParams.new( @params )
      end
    end

    def self.detect( img, params )
      params = params.to_CvStarDetectorParams unless  params.is_a?( CvStarDetectorParams )
      raise ArgumentError unless params.is_a?( CvStarDetectorParams ) 

      img = img.to_IplImage.ensure_greyscale
      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      keypoints = CVFFI::CvSeq.new CVFFI::cvGetStarKeypoints( img, mem_storage, params )
      Results.new( keypoints, mem_storage )
    end
  end
end
