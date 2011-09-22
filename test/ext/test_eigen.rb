
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi-ext/eigen'
require 'benchmark'

class TestEigen < Test::Unit::TestCase

  def setup
  end

  def random_matrix( x, y )
    a = CVFFI::CvMat.new CVFFI::cvCreateMat( x, y, :CV_32F )
    x.times { |i|
      y.times { |j|
        CVFFI::cvSetReal2D( a, i, j, rand )
      }
    }
    a
  end

  def test_svd

    a = random_matrix( 3,3 )

    w,u,v = CVFFI::Eigen::svd( a )

    CVFFI::print_matrix a, {:caption => "a"}
    CVFFI::print_matrix w, {:caption => "w"}
    CVFFI::print_matrix u, {:caption => "u"}
    CVFFI::print_matrix v, {:caption => "v"}

  end

  def test_poly

    # Should be coefficients for (t-1)(t-2)...(t-6) in ascending
    # coefficient order...
    coeffs = [ 720.0, -1764.0, 1624.0, -735.0, 175.0, -21.0, 1.0 ]
    # Eigen expects polynomial in ascending order
    roots = CVFFI::Eigen::polySolver( coeffs )
    roots.sort!


    epsilon = 1e-6
    6.times { |i|
      assert_in_delta roots[i], (i+1).to_f,  epsilon
    }

  end

end
