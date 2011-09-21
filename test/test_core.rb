require 'test/setup'
require 'opencv-ffi/core'
require 'find'

recursive_test 'core'

class TestCore < Test::Unit::TestCase

  def test_cvPoint
    p = CVFFI::CvPoint.new( {:x => 1, :y => 2} )

    assert_not_nil p
    assert_equal 1, p.x
    assert_equal 2, p.y
  end

  def test_createImg
    img = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>100, :height=>100 ), 8, 1 )

    assert_not_nil img
    assert_equal 1, img.nChannels
    assert_equal 8, img.depth

  end

end
