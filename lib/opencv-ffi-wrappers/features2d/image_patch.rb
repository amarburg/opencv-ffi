require 'opencv-ffi'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/point'
require 'opencv-ffi-ext/eigen'

module CVFFI

  module ImagePatch

    class Mask
      attr_reader :size
      def initialize(size)
        @size = size
      end
    end

    class SquareMask < Mask
      def initialize(size)
        super(size)
      end
      def valid?(i,j)
        raise "Requesting point outside mask" unless ((0...@size).include? i and (0...@size).include? j) 
        true
      end
    end

    class CircularMask < Mask
      def initialize(size)
        super(size)

        @mask = build_circle( size/2.0 )
      end

      def build_circle( radius )
        ## Returns row-major Array of Arrays
        center = CVFFI::Point.new(radius,radius)
        @mask = Array.new(radius.ceil) { |i|
          Array.new(radius.ceil) { |j|
            pt = CVFFI::Point.new( 0.5 + j, 0.5 + i )
            center.l2distance( pt ) <= radius ? true : false
          }
        }

        # Now mirror the one quadrant across Y, then across X
        @mask.map! { |a| a + a.reverse }
        @mask + @mask.reverse
      end

      def valid?(i,j)
        @mask[i][j]
      end
    end

    class Result 

      attr_accessor :center
      attr_accessor :patch
      attr_accessor :mask
      attr_accessor :angle

      def initialize( center, patch, mask, angle = 0.0 )
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
        @mask = mask
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

      def initialize( params )
        @params = params
      end

      def patch_size
        @params.size
      end


      def draw_index_image( opts = {} )
        border = 5
        max_cols = opts[:max_cols] || 20 

        # Aim for square index
        cols = Math::sqrt(size).ceil
        cols = [cols,max_cols].min

        rows = (size*1.0/cols).ceil
      #  puts "Building index #{cols} x #{rows}"
      #  puts "Image patch size #{patch_size}"

        img_size = CVFFI::CvSize.new( [ (cols)*(patch_size+border) + border, (rows)*(patch_size+border) + border ] )

        img = CVFFI::cvCreateImage(img_size, 8, 1 )
        CVFFI::cvSet( img, CVFFI::CvScalar.new( [ 200.0,0.0,0.0,0.0 ] ), nil )

        each_with_index { |patch,i|
          c = i%cols
          r = (i/cols).floor

          xoffset = c*(patch_size+border)+border
          yoffset = r*(patch_size+border)+border

      #    puts "Offsets: #{xoffset} x #{yoffset}"

          a = patch.patch.to_a
          a.each_with_index { |row,i|
            row.each_with_index { |value,j|
              if patch.mask.valid?(i,j)
                CVFFI::cvSet2D( img, yoffset+i, xoffset+j, CVFFI::CvScalar.new( [ value, 0, 0, 0 ] ) )
              end
            }
          }
        }

        img
      end
    end

    class Params

      DEFAULTS = { size: 9,
        oriented: false,
        shape: :square }

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
      results = ResultsArray.new( params )
      keypoints.each { |kp|
        next if kp.x < half_size or 
        kp.y < half_size or
        (img.width - kp.x) <= half_size or
        (img.height - kp.y) <= half_size

        angle = 0.0
        rect = Rect.new( [ kp.x-half_size, kp.y-half_size, params.size, params.size ] )
        CVFFI::cvSetImageROI( img, rect.to_CvRect )

        case params.shape
        when :square
          mask = SquareMask.new( params.size )
        when :circle, :circular
          mask = CircularMask.new(params.size )
        else 
          raise "Don't know how to make shape #{params.shape}"
        end

        ## Simple single-channel implementation
        #  Patch is row-major (i == row == y, j = column == x)
        patch = Array.new( params.size ) { |i|
          Array.new( params.size ) { |j|
             mask.valid?(i,j) ?  CVFFI::cvGetReal2D( img, i,j ) : 0.0
          }
        }

        if params.oriented  == true
          # Calculate covariance matrix by Yingen Xiong
          patch_sum = mxi = mxj = 0.0
          patch.each_index { |i|
            patch[i].each_index { |j|
              if mask.valid?(i,j)
                patch_sum += patch[i][j]
                mxi += i*patch[i][j]
                mxj += j*patch[i][j]
              end
            }
          }
          mxi /= patch_sum
          mxj /= patch_sum

          puts "Medoids = " + [mxi,mxj].join(',')

          c11 = c12 = c22 = 0.0
          patch.each_index { |i|
            patch[i].each_index { |j|
              if mask.valid?(i,j)
                c11 += patch[i][j] * (i-mxi)*(i-mxi)
                c12 += patch[i][j] * (i-mxi)*(j-mxj)
                c22 += patch[i][j] * (j-mxj)*(j-mxj)
              end
            }
          }

          c = Matrix.rows( [ [c11,c12],[c12,c22] ] )
          puts "c = "
          c.to_a.each { |r| puts r.join(' ') }
          d,v = CVFFI::Eigen.eigen( c )

          puts "d = "
          puts d.to_Matrix
          puts "v = "
          puts v.to_Matrix

          d = d.to_a
          i = if d[0] == d[1]
                # Equal eigenvalues
                0
              else
                d.find_index( d.max )
              end

          puts "eigenvalue #{i} is larger"
          vec = v.to_Matrix.column_vectors[i]

          # Eigenvector corresponding to larger eignvector defines orientation
          #  However it's in i-j space, which is OpenCV (y-down, x-right)
          #  Subtract from 2PI to put in mathematical (x-right, y-up) space
          angle = 2*Math::PI - Math::atan2( vec[0],vec[1] )
          angle %= 2*Math::PI
          puts "Computed angle #{angle * 180.0/Math::PI}"

        end

        results << Result.new( kp, patch, mask, angle )
      }

      results
    end
  end
end

