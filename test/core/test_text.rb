
require 'test/setup'
require 'lib/opencv-ffi/core'

class TestCoreTextFunctions < Test::Unit::TestCase

  def setup
    @img = CVFFI::cvLoadImageM( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end


  def test_cvInitFont
    font = CVFFI::CvFont.new '\0'
    CVFFI::cvInitFont( font, :CV_FONT_HERSHEY_PLAIN, 2.0, 2.0, 0.0, 1, 8 )

    assert_equal CVFFI::CvFontDefines[:CV_FONT_HERSHEY_PLAIN], font.font_face
    assert_equal 2.0, font.hscale
    assert_equal 2.0, font.vscale
    assert_equal 1, font.thickness
    assert_equal 0.0, font.shear
    assert_equal 8, font.line_type
  end

  def test_putText
    font = CVFFI::CvFont.new '\0'
    CVFFI::cvInitFont( font, :CV_FONT_HERSHEY_PLAIN, 2.0, 2.0, 0.0, 5, 8 )

    img = CVFFI::cvCreateImage( CVFFI::CvSize.new( :height=>480, :width=>640), :IPL_DEPTH_32F, 3 )

    color = CVFFI::CvScalar.new( :w => 0 , :x => 255, :y => 0, :z => 0 )
    point = CVFFI::CvPoint.new( :x => 100, :y => 100 )

    a = "TEST TEST!"
    CVFFI::cvPutText( img, a, point, font, color )

    CVFFI::cvSaveImage( TestSetup::output_filename("fontTest.tif"), img )


    size = CVFFI::CvSize.new :height => 0, :width => 0
    objptr = FFI::MemoryPointer.new :int
    CVFFI::cvGetTextSize( a, font, size, objptr )
    baseline = objptr.read_int

    ## These are pre-calculated values
    assert_equal 12, baseline
    assert_equal 191, size.width
    assert_equal 21, size.height
  end



end
