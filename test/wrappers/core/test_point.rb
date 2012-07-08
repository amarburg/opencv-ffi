
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi-wrappers/core'

class TestCorePointWrappers < Test::Unit::TestCase

  def test_point
    p = CVFFI::Point.new( 10.0, 0.0 )
    r = CVFFI::Point.new( 0.0, 0.0 )

    assert_equal 10.0, p.x
    assert_equal  0.0, p.y

    q = p.to_CvPoint
    assert_equal 10.0, q.x
    assert_equal  0.0, q.y

    q = p.to_a
    assert q.is_a?(Array)
    assert_equal 3, q.length
    assert_equal 10.0, q[0]
    assert_equal 0.0,  q[1]
    assert_equal 1.0,  q[2]

    q = p.to_a(false)
    assert q.is_a?(Array)
    assert_equal 2, q.length
    assert_equal 10.0, q[0]
    assert_equal 0.0,  q[1]

    q = p.rotate( 0.0 )
    assert_equal 10.0, q.x
    assert_equal  0.0, q.y

    q = p.rotate( Math::PI/2.0 )
    assert_in_delta 0.0, q.x, TestSetup::EPSILON
    assert_in_delta 10.0, q.y, TestSetup::EPSILON

    assert p.neighbor?( r, 10.01 )
    assert p.neighbor?( r, 9.99 ) == false

    assert p.neighbor_rsquared?( r, 100.01 )
    assert p.neighbor_rsquared?( r, 99.9 ) == false

    assert_in_delta 10.0, p.l2distance( r ),  TestSetup::EPSILON
    assert_in_delta 100.0, p.l2_squared_distance( r ),  TestSetup::EPSILON
  end

  def test_distance_from_line_to_point
    # Line at 45deg through origin
    line =  CVFFI::Line.new( 1, 1, 0 )
    point = CVFFI::Point.new( 2.0, 0.0 )

    # Test the function both ways (point -> line and line -> point)
    d = point.distance_to line
    assert_in_delta Math::sqrt(2.0), d, TestSetup::EPSILON

    d = line.distance_to point 
    assert_in_delta Math::sqrt(2.0), d, TestSetup::EPSILON
  end

  def test_normal_through_point
    # Line at 45deg through origin
    line =  CVFFI::Line.new( 1, 1, 0 )
    point = CVFFI::Point.new( -1.0, -1.0 )

    normal = line.normal_through( point ).normalize

    # There's a family of answers, but these tests should catch the correct
    # answer
    assert_in_delta -1.0, (normal.x/normal.y), TestSetup::EPSILON
    assert_in_delta  0.0, normal.z, TestSetup::EPSILON


  end

end
