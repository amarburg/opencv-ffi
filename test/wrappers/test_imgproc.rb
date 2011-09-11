

require 'test/setup'
require 'opencv-ffi-wrappers/core/point'
require 'opencv-ffi-wrappers/imgproc'
require 'opencv-ffi-wrappers/misc'

class TestImgprocWrappers < Test::Unit::TestCase

  def setup
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

end
