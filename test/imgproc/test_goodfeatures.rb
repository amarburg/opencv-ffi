require 'test/setup'
require 'opencv-ffi'
require 'find'

class TestGoodFeaturesToTrack < Test::Unit::TestCase

  def test_goodFeaturesToTrack
    # First, the "verbatim" approach, with some rubbish data
    img = TestSetup::grey_test_image
    eigImage = CVFFI::cvCreateMat( img.width, img.height, :CV_32F )
    tmpImage = CVFFI::cvCreateMat( img.width, img.height, :CV_32F )

    max_corners = 100
    corners = CVFFI::cvGoodFeaturesToTrack( img, eigImage, tmpImage, max_corners, 0.5, 5 )

    assert corners.length <= max_corners
  end
end
