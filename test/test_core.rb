
require 'test/setup'
require 'opencv-ffi/core'

class TestOpenCVFFICore < Test::Unit::TestCase

  def test_cvPoint
    p = CVFFI::CvPoint.new( {:x => 1, :y => 2} )

    assert_not_nil p
    assert_equal 1, p.x
    assert_equal 2, p.y
  end

end
