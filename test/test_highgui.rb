
require 'test/setup'
require 'opencv-ffi/highgui'

class TestFFI < Test::Unit::TestCase

  def test_cvLoadImageM_cvSaveImage
    cvmat = TestSetup::test_mat

    assert_not_nil cvmat
    assert_equal cvmat.width, 3888
    assert_equal cvmat.height, 2592

    CVFFI::cvSaveImage( TestSetup::output_filename("asCvMat.jpg"), iplimage.to_ptr )
  end

  def test_cvLoadImageM_cvSaveImage
    iplimage = TestSetup::test_image

    assert_not_nil iplimage
    assert_equal iplimage.width, 3888
    assert_equal iplimage.height, 2592

    CVFFI::cvSaveImage( TestSetup::output_filename("asIplImage.jpg"), iplimage.to_ptr )
  end
end
