

require 'test/setup'
require 'opencv-ffi-wrappers/core'
require 'opencv-ffi-wrappers/imgproc'
require 'opencv-ffi-wrappers/misc'

class TestImgprocWrappers < Test::Unit::TestCase

  def setup
        @img = CVFFI::cvLoadImage( TEST_IMAGE_FILE, CVFFI::CV_LOAD_IMAGE_COLOR  )
  end

  def test_getAffineTransform
    src = Array.new(5) { |i|
      CVFFI::Point.new( 1.1, i*1.0 )
    }
    dst = Array.new(5) { |i|
      CVFFI::Point.new( i*1.0, i* -1.0 )
    }

    result = CVFFI::get_affine_transform(src,dst)

    assert_not_nil result

    CVFFI::print_matrix(result, :format => :e)

 end

  def test_warpAffine
    warp = CVFFI::CvMat.new CVFFI::cvCreateMat(2,3,:CV_32F)
    CVFFI::cvSetReal2D(warp, 0,0,1.0)
    CVFFI::cvSetReal2D(warp, 0,1,0.0)
    CVFFI::cvSetReal2D(warp, 0,2,0.0)
    CVFFI::cvSetReal2D(warp, 1,0,0.0)
    CVFFI::cvSetReal2D(warp, 1,1,1.0)
    CVFFI::cvSetReal2D(warp, 1,2,0.0)

    dst = CVFFI::cvCreateImage( @img.image_size.to_CvSize, @img.depth, @img.nChannels ) 

    out = CVFFI::warp_affine( @img.to_IplImage, dst, warp )

    CVFFI::cvSaveImage( TestSetup::output_filename("affineWarped.jpg"), dst )

  end

end
