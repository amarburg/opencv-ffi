

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/opensurf'

class TestOpenSURF < Test::Unit::TestCase

  def setup
  end


  def test_openSurfDetect
    img = TestSetup::test_image

    params = CVFFI::OpenSURF::Params.new

    # This should test the auto=conversion to greyscale
    surf = CVFFI::OpenSURF::detect( img, params )

    assert_not_nil surf

    surf.mark_on_image( img, {:radius=>5, :thickness=>-1} )
    CVFFI::cvSaveImage( TestSetup::output_filename("openSurfPts.jpg"), img )

    puts "OpenSURF detected #{surf.length} points"


    descriptors = CVFFI::OpenSURF::describe( img, surf, params )

    puts "After description #{descriptors.length} points"
 end

end
