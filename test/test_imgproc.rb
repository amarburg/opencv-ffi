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

    CVFFI::cv2DRotationMatrix( center, 1.0, 1.0, mat )

  end

end
