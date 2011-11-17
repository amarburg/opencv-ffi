
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/sift'

class TestSIFT < Test::Unit::TestCase

  def setup
  end


  def test_siftDetect
    img = TestSetup::small_test_image

    params = CVFFI::SIFT::Params.new( octaves: 1 )

    # This should test the auto=conversion to greyscale
    sift = CVFFI::SIFT::detect( img, params )

    assert_not_nil sift

#    surf.mark_on_image( img, {:radius=>5, :thickness=>-1} )
#    CVFFI::cvSaveImage( TestSetup::output_filename("openSurfPts.jpg"), img )

#    puts "OpenSURF detected #{surf.length} points"


#    descriptors = CVFFI::OpenSURF::describe( img, surf, params )

#    puts "After description #{descriptors.length} points"
 end

end
