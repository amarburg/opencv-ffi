
require 'test/setup'
require 'opencv-ffi-wrappers/core'

class TestCoreTypesWrappers < Test::Unit::TestCase

  def test_Size
    p = CVFFI::CvSize.new( {:width => 1, :height => 2} )


    assert_equal 1, p.x
    assert_equal 2, p.y

    assert_equal 1, p.width
    assert_equal 2, p.height

    p.x = 3

    assert_equal 3, p.width
    assert_equal 2, p.height
    assert_equal 3, p.x
    assert_equal 2, p.y

  end

end
