
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi-ext/eigen'
require 'matrix'

class TestEigen < Test::Unit::TestCase

  def setup
    @a = CVFFI::cvCreateMat( 3,3, :CV_32F )
    3.times {|i| 3.times {|j|
      @a.set_f( i,j,3*i+j+1)
    }}
    @epsilon = 1e-3
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
    # Test matrix [ 1,2,3
    #               4,5,6
    #               7,8,9 ]
    a = @a
    u,d,v = CVFFI::Eigen::svd( a )

    CVFFI::print_matrix a, {:caption => "a"}
    CVFFI::print_matrix u, {:caption => "w"}
    CVFFI::print_matrix d, {:caption => "u"}
    CVFFI::print_matrix v, {:caption => "v"}


    ## Test results from alpha
    uans = Matrix.rows( [ [0.214837 , 0.887231 , 0.408248 ],
                       [0.520587 , 0.249644 , -0.816497 ],
                       [0.826338 , -0.387943 , 0.408248 ] ] )
    dans = [16.8481 , 1.06837 , 0.0 ]
    vans = Matrix.rows( [ [0.479671 , -0.776691 , 0.408248 ],
                       [0.572368 , -0.0756865 , -0.816497],
                       [0.665064 , 0.625318 , 0.408248] ] )

    # Check the SVDs
    dans.each_with_index { |dans,i| assert_in_delta d.at_f(i,0), dans, @epsilon }

    3.times{ |j| 
      # Check the original matrix
      3.times { |i|
        assert_equal a.at_f( i,j ), 3*i+j+1 
      }
      2.times { |i|
        # Because there's scalar ambiguity in the third column
        # check ratios instead
        assert_in_delta u.at_f(i,j)/u.at_f(i+1,j), uans[i,j]/uans[i+1,j], @epsilon
        assert_in_delta v.at_f(i,j)/v.at_f(i+1,j), vans[i,j]/vans[i+1,j], @epsilon
      }
    }
  end

  def test_eigen
    a = @a
    d,v = CVFFI::Eigen::eigen(a)

    CVFFI::print_matrix d, {:caption=>"d"}
    CVFFI::print_matrix v, {:caption=>"v"}

    # From Wolfram alpha
    dans = [ 16.1168, -1.11684, 0 ]
    vans = [[0.283349, 0.641675, 1.0], [-1.28335, -0.141675, 1.0], [1.0, -2.0, 1.0 ] ]

    3.times { |i|
      assert_in_delta d.at_f(i,0), dans[i], @epsilon

      # Ratio test on elements of eigenvectors
      assert_in_delta v.at_f(0,i)/v.at_f(1,i), vans[i][0]/vans[i][1], @epsilon
      assert_in_delta v.at_f(0,i)/v.at_f(2,i), vans[i][0]/vans[i][2], @epsilon
    }



  end

  def test_poly

    # Should be coefficients for (t-1)(t-2)...(t-6) in ascending
    # coefficient order...
    coeffs = [ 720.0, -1764.0, 1624.0, -735.0, 175.0, -21.0, 1.0 ]
    # Eigen expects polynomial in ascending order
    roots = CVFFI::Eigen::polySolver( coeffs )
    roots.sort!


    6.times { |i|
      assert_in_delta roots[i], (i+1).to_f,  @epsilon
    }

  end

end
