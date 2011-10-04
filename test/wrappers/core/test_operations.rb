
require 'test/setup'
require 'opencv-ffi-wrappers/core'


class TestCoreWrapperOperations < Test::Unit::TestCase

    WHITE  = CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )
    BLACK = CVFFI::CvScalar.new( {:w=>0, :x=>0, :y=>0, :z=>0} )

  def setup
  end

  def test_solve_cubic
    # The roots of x^3 - 6x^2 + 11x - 6
    # are 1,2,3
    c = Vector[1,-6,11,-6]
    r = CVFFI::solveCubic( c )

    p r
    assert r.is_a?(Vector)
    assert_equal 3, r.size

    # For simplicity, dump to an array I can sort
    r = r.covector.sort

    3.times { |i|
      assert_in_delta i+1, r[i], 1e-06
    }
  end




end
