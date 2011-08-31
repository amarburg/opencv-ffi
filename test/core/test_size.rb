
require 'test/setup'

class TestCoreSize < Test::Unit::TestCase

  def test_cvSize
    p = CVFFI::CvSize.new( {:width => 1, :height => 1} )

    assert_not_nil p
    assert_equal 1, p.width
    assert_equal 1, p.height
  end

end
