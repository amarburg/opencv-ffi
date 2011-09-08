
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/matcher'

class TestMatchers < Test::Unit::TestCase

  def setup
    @img_one = TestSetup::load_test_image
    @img_two = TestSetup::load_second_test_image
  end

  def extract_surf(img)
    smallImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => img.height/2,
                                                              :width => img.width/2 } ),
                                    img.depth, img.nChannels )

    CVFFI::cvResize( img, smallImg, :CV_INTER_LINEAR )


    params = CVFFI::CvSURFParams.new( :hessianThreshold => 500.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 3,
                                      :nOctaveLayers => 4 )

    # This should test the auto=conversion to greyscale
    surf = CVFFI::SURF::Detect( smallImg, params )

    assert_not_nil surf

    surf
  end
 

  def test_matcher

    surf_one = extract_surf( @img_one )
    surf_two = extract_surf( @img_two )

 end

end
