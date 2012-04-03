
require 'test/setup'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-ext/color_invariance'

class TestColorInvariance < Test::Unit::TestCase

  include CVFFI::ColorInvariance

  def setup
    @img_one = TestSetup::test_image
  end

  def test_one
    out = @img_one.clone

    cvCvtColorInvariants( @img_one, out, :CV_COLOR_INVARIANCE_FOO )

    assert_not_nil out
  end

end
