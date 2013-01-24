

require 'test/setup'
require 'opencv-ffi/core'


class TestRandFunctions < Test::Unit::TestCase
  include CVFFI


  def setup
  end


  def test_rng
    rng = CVFFI::cvRNG
  end

  def test_rand_arr
    rng = CVFFI::cvRNG
    mat = CVFFI::cvCreateMat( 100, 100, :CV_32F )
    CVFFI::cvRandArr( rng.pointer, mat, :CV_RAND_UNI, 
              CvScalar.new({ :w => 0, :x => 0, :y => 0, :z => 0 } ),
              CvScalar.new({ :w => 1, :x => 0, :y => 0, :z => 0 } ) )

    (mat.height).times { |r|
      (mat.width).times { |c|
        at = cvGetReal2D( mat, r, c)
        assert at >= 0.0
        assert at <= 1.0
      }
    }
  end
end
