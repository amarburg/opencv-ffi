

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/features2d/star'

class TestSTAR < Test::Unit::TestCase

  def setup
    @img = TestSetup::test_image
  end


  def test_cvExtractSTAR

    params = CVFFI::STAR::Params.new
    star = CVFFI::STAR::detect( @img, params )
    assert_not_nil star

    star.mark_on_image( @img, {:radius=>5, :thickness=>-1} )
    CVFFI::cvSaveImage( TestSetup::output_filename("starWrapperPts.jpg"), @img )

    ## Test some of the functions built into STAR::Result
    p star[0]
 end

end
