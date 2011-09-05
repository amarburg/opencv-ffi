require 'test/setup'
require 'opencv-ffi/imgproc'
require 'opencv-ffi/core'
require 'find'

Find.find( 'test/imgproc/' ) { |f|
  require f if f.match( "test/imgproc/test_[\w]*" )
}

class TestImgproc < Test::Unit::TestCase

  def test_cv2DRotationMatrix

    center = CVFFI::CvPoint2D32f.new( :x => 0.0, :y => 0.0 )
    mat = CVFFI::cvCreateMat( 2,3, :CV_32F )

    CVFFI::cv2DRotationMatrix( center, 0.0, 1.0, mat )

    # With 0 rotation, some elements should be 0.0
   
    assert_in_delta 0.0, CVFFI::cvGetReal2D( mat, 0, 1 ), TestSetup::EPSILON
    assert_in_delta 0.0, CVFFI::cvGetReal2D( mat, 1, 0 ), TestSetup::EPSILON
    assert_in_delta CVFFI::cvGetReal2D( mat, 0, 0), CVFFI::cvGetReal2D( mat, 1, 1 ), TestSetup::EPSILON

    a = []
    0.upto(1) { |i|
      b = []
      0.upto(2) { |j|
        b << CVFFI::cvGetReal2D( mat, i,j )
      }
      a << b
    }

p a
  end

end
