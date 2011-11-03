

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/features2d/surf'

class TestSURF < Test::Unit::TestCase

  def setup
  end


  def test_cvExtractSURF

    params = CVFFI::CvSURFParams.new( :hessianThreshold => 500.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 3,
                                      :nOctaveLayers => 4 )

    # This should test the auto=conversion to greyscale
    surf = CVFFI::SURF::detect( @img.ensure_greyscale, params )

    assert_not_nil surf

    surf.mark_on_image( @img, {:radius=>5, :thickness=>-1} )
    CVFFI::cvSaveImage( TestSetup::output_filename("surfWrapperPts.jpg"), @img )

    ## Test some of the functions built into SURF::Result
    p surf[0]
    puts surf[0].distance_to( surf[1] )
    puts surf[1].distance_to( surf[2] )
 end

end
