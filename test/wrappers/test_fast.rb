
require 'test/setup'
require 'opencv-ffi-wrappers/fast'
require 'opencv-ffi-wrappers/core/iplimage'

class TestSURF < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def test_cvFASTDetector
#    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
#                                                         :width => @img.width }), 
#                                    :IPL_DEPTH_8U, 1 )
#    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    greyImg = @img.ensure_greyscale

    smallGreyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => greyImg.height/2,
                                                              :width => greyImg.width/2 } ),
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvResize( greyImg, smallGreyImg, :CV_INTER_LINEAR )

results = CVFFI::FAST::FAST9Detect( smallGreyImg, 50 )

    results.each { |pt|
      CVFFI::cvCircle( smallGreyImg, CVFFI::CvPoint.new( :x => pt.x.to_i, :y => pt.y.to_i ), 5,
                      CVFFI::CvScalar.new( :w=>255, :x=>255, :y=>255, :z=>0 ), -1, 8, 0 )
    }
    CVFFI::cvSaveImage( TestSetup::output_filename("greyImageFASTWrapperPts.jpg"), smallGreyImg )

 end

end
