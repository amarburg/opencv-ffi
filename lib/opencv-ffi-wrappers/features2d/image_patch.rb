require 'opencv-ffi'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/point'

module CVFFI

  module ImagePatch

    class Result 

      attr_accessor :center
      attr_accessor :patch
      attr_accessor :angle

      def initialize( center, patch, angle = 0.0 )
        @center = CVFFI::Point.new center
        case patch
        when Matrix
          @patch = patch
        when Array
        @patch = Matrix.rows( patch )
        else 
          raise "Don't know how to handle type #{patch.class}"
        end
        @angle = angle
      end

      def ==(b)
        @center == b.center and
        @angle == b.angle and
        @patch == b.patch
      end


      def to_a

      end
   end

    class ResultsArray < Array

    end

    class Params

      DEFAULTS = { size: 9,
                   upright: false }

      def initialize( opts = {} )

        @params = {}
        DEFAULTS.each_key { |k|
          @params[k] = (opts[k] or DEFAULTS[k])
          define_singleton_method( k ) { @params[k] }
        }
      end

      def check_params
        raise "Image patches need to be odd" unless size.odd?
      end

      def to_hash
        @params
      end
    end

    def self.describe( img, keypoints, params )
      img = img.to_IplImage.ensure_greyscale

      half_size = (params.size/2).floor
      results = ResultsArray.new
      keypoints.each { |kp|
        next if kp.x < half_size or 
                kp.y < half_size or
                (img.width - kp.x) <= half_size or
                (img.height - kp.y) <= half_size

        angle = 0.0
        rect = Rect.new( [ kp.x-half_size, kp.y-half_size, params.size, params.size ] )
        CVFFI::cvSetImageROI( img, rect.to_CvRect )

        ## Simple single-channel implementation
        patch = Array.new( params.size ) { |i|
          Array.new( params.size ) { |j|
             CVFFI::cvGetReal2D( img, i, j )
          }
        }

        if params.upright
          
        end

        results << Result.new( kp, patch, angle )
      }

      results
    end
  end
end

