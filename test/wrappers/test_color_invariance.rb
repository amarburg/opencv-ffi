
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

    e, el, ell = out.split

    el_colored = CVFFI::cvCreateImage( el.image_size.to_CvSize, :IPL_DEPTH_8U, 3 )
    cvCvtColorInvariants( el, el_colored, :CV_COLOR_INVARIANCE_Gray2YB )
    ell_colored = CVFFI::cvCreateImage( ell.image_size.to_CvSize, :IPL_DEPTH_8U, 3 )
    cvCvtColorInvariants( ell, ell_colored, :CV_COLOR_INVARIANCE_Gray2RG  )

    TestSetup::save_image("color_invariance_gaussian_opponent_e", e )
    TestSetup::save_image("color_invariance_gaussian_opponent_el", el_colored )
    TestSetup::save_image("color_invariance_gaussian_opponent_ell", ell_colored )
  end

  def test_lab
    out = @img_one.clone
    CVFFI::cvCvtColor( @img_one, out, :CV_BGR2Lab )
    assert_not_nil out
    TestSetup::save_image("color_invariance_lab", out )

    e, el, ell = out.split

    el_colored = CVFFI::cvCreateImage( el.image_size.to_CvSize, :IPL_DEPTH_8U, 3 )
    cvCvtColorInvariants( el, el_colored, :CV_COLOR_INVARIANCE_Gray2YB )
    ell_colored = CVFFI::cvCreateImage( ell.image_size.to_CvSize, :IPL_DEPTH_8U, 3 )
    cvCvtColorInvariants( ell, ell_colored, :CV_COLOR_INVARIANCE_Gray2RG )

    TestSetup::save_image("color_invariance_lab_l", e )
    TestSetup::save_image("color_invariance_lab_a", el_colored )
    TestSetup::save_image("color_invariance_lab_b", ell_colored )
  end


end
