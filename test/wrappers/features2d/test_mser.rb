

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/features2d/mser'

class TestMSER < Test::Unit::TestCase

  def setup
    @img = TestSetup::test_image
  end

  def test_cvExtractMSER

    params = CVFFI::MSER::Params.new
    mser = CVFFI::MSER::detect( @img, params )
    assert_not_nil mser

    ## Test some of the functions built into ::Result
    ##p star[0]
 end

end
