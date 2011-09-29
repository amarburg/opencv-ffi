

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/surf'

class TestSURF < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvExtractSURF

#    greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height, 
#                                                         :width => @img.width }), 
#                                    :IPL_DEPTH_8U, 1 )
#    CVFFI::cvCvtColor( @img, greyImg, :CV_RGB2GRAY )

    smallImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => @img.height/2,
                                                              :width => @img.width/2 } ),
                                    @img.depth, @img.nChannels )

    CVFFI::cvResize( @img, smallImg, :CV_INTER_LINEAR )


    params = CVFFI::CvSURFParams.new( :hessianThreshold => 500.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 3,
                                      :nOctaveLayers => 4 )

    # This should test the auto=conversion to greyscale
    surf = CVFFI::SURF::detect( smallImg, params )

    assert_not_nil surf
    #p surf.inspect

    surf.mark_on_image( smallImg, {:radius=>5, :thickness=>-1} )
    CVFFI::cvSaveImage( TestSetup::output_filename("surfWrapperPts.jpg"), smallImg )

    ## Test some of the functions built into SURF::Result
    p surf[0]
    puts surf[0].distance_to( surf[1] )
    puts surf[1].distance_to( surf[2] )
 end

end
