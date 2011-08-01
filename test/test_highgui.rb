
require 'test/setup'
require 'opencv-ffi/highgui'

class TestFFI < Test::Unit::TestCase

  def test_cvLoadImageM_cvSaveImage

    cvmat = CVFFI::cvLoadImageM( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )

    assert_not_nil cvmat
    assert_equal cvmat.width, 3888
    assert_equal cvmat.height, 2592

    CVFFI::cvSaveImage( TEST_IMAGE_OUTPUT, cvmat.to_ptr )
  end

end
