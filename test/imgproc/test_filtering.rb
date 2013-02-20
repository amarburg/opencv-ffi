
require 'test/setup'
require 'opencv-ffi'
require 'find'

# TODO:  More comprehensive testing.
class TestFiltering < Test::Unit::TestCase

  def test_smooth
    # First, the "verbatim" approach, with some rubbish data
    img = TestSetup::grey_test_image
    smoothedImage = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => img.height, 
                                                      :width => img.width }), 
                                                      :IPL_DEPTH_8U, 1 )
 
    CVFFI::cvSmooth( img, smoothedImage, :CV_GAUSSIAN, 0, 0, 1.4, 0 )
  end
end
