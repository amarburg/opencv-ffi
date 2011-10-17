require 'opencv-ffi'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/point'
require 'opencv-ffi-ext/eigen'

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

        if params.upright == false
          # Calculate covariance matrix by Yingen Xiong
          patch_sum = mxi = mxj = 0.0
          patch.each_index { |i|
            patch[i].each_index { |j|
              patch_sum += patch[i][j]
              mxi += i*patch[i][j]
              mxj += j*patch[i][j]
            }
          }
          mxi /= patch_sum
          mxj /= patch_sum

          c11 = c12 = c22 = 0.0
          patch.each_index { |i|
            patch[i].each_index { |j|
              c11 += patch[i][j] * (i-mxi)*(i-mxi)
              c12 += patch[i][j] * (i-mxi)*(j-mxj)
              c22 += patch[i][j] * (j-mxj)*(j-mxj)
            }
          }

          c = Matrix.rows( [ [c11,c12],[c12,c22] ] )
          d,v = CVFFI::Eigen.eigen( c )

          d = d.to_Matrix
          v = v.to_Matrix


          puts d
          puts v

          
        end

        results << Result.new( kp, patch, angle )
      }

      results
    end
  end
end

