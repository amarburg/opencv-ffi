
require 'test/setup'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-ext/color_invariance'

class TestColorInvariance < Test::Unit::TestCase

  include CVFFI::ColorInvariance

  def setup
    @img_one = TestSetup::test_image
  end

  def test_passthrough
    out = @img_one.clone
    cvCvtColorInvariants( @img_one, out, :CV_COLOR_INVARIANCE_PASSTHROUGH )
    assert_not_nil out
    TestSetup::save_image("color_invariance_passthrough.jpg", out )
  end

  def test_opponent_gaussian
    out = @img_one.clone
    cvCvtColorInvariants( @img_one, out, :CV_COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT )
    assert_not_nil out
    TestSetup::save_image("color_invariance_gaussian_opponent.jpg", out )
  end

end
