
require 'test/setup'
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


end
