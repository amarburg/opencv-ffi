

require 'test/setup'
require 'opencv-ffi-wrappers/core/misc_draw'

class TestDrawWrappers < Test::Unit::TestCase

  def setup
    @img = TestSetup.load_test_image
  end

  def test_draw_point
    p = CVFFI::Point.new( 500.0, 500.0 )

    opts = { :radius => 50 }
    CVFFI::draw_point( @img, p, opts)

    CVFFI::cvSaveImage( TestSetup.output_filename("TestDrawPointWrapper.jpg"), @img )

  end
end
