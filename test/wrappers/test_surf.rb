

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/surf'

class TestSURF < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvExtractSURF

    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
                                                         :width => @img.width }), 
                                    :IPL_DEPTH_8U, 1 )
    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    smallGreyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => greyImg.height/2,
                                                              :width => greyImg.width/2 } ),
                                    :IPL_DEPTH_8U, 1 )

    CVFFI::cvResize( greyImg, smallGreyImg, :CV_INTER_LINEAR )


    params = CVFFI::CvSURFParams.new( :hessianThreshold => 500.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 3,
                                      :nOctaveLayers => 4 )

    surf = CVFFI::SURF::Detect( smallGreyImg, params )

    assert_not_nil surf
    p surf.inspect

    surf.each { |kp|
      p kp.inspect

      # cvCircle takes a CvPoint(int), but the CvSURFPoint contains CvPoint2D32f, need 
      # to manually typecast...
      CVFFI::cvCircle( smallGreyImg, CVFFI::CvPoint.new( :x => kp.pt.x.to_i, :y => kp.pt.y.to_i ), 5,
                      CVFFI::CvScalar.new( :w=>255, :x=>255, :y=>255, :z=>0 ), -1, 8, 0 )
    }
    CVFFI::cvSaveImage( TestSetup::output_filename("surfWrapperPts.jpg"), smallGreyImg )
 end

end
