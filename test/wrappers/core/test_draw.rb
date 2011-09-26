

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

  def test_put_text
    font = CVFFI::CvFont.new '\0'
    CVFFI::cvInitFont( font, :CV_FONT_HERSHEY_PLAIN, 2.0, 2.0, 0.0, 5, 8 )
    img = CVFFI::cvCreateImage( CVFFI::CvSize.new( :height=>480, :width=>640), :IPL_DEPTH_32F, 3 )

    color = CVFFI::Scalar.new( 0, 255, 0, 0, )
    point = CVFFI::Point.new( 100, 100 )

    a = "TEST TEST!"
    CVFFI::put_text( img, a, point, { :font => font, :color => color } )

    color[:r] = 255
    CVFFI::put_text( img, a, point*2, { :face => :CV_FONT_HERSHEY_SIMPLEX,
                                        :scale => 2.0,
                                        :color => color } )

    CVFFI::cvSaveImage( TestSetup::output_filename("fontWrapperTest.tif"), img )
  end


end
