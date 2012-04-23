
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi-wrappers/core'

class TestCoreMat < Test::Unit::TestCase

  def test_MatInitializerDefaultType
    # Default type is 32F
    a = CVFFI::Mat.new( 5,5 )

    a[1,2] = 1.0
    assert_equal 1.0, a[1,2]
  end


  def test_MatInitializerIntType
    a = CVFFI::Mat.new( 5,5, :CV_8U )

    a[1,2] = 1.0
    assert_equal 1, a[1,2]
  end

  def test_MatInitializeFromRows
    a = [ [1,2,3],[4,5,6],[7,8,9] ]
    m = CVFFI::Mat.rows( a, :CV_8U )

    m.each_with_indices { |d,i,j|
      assert_equal a[i][j], d
    }
  end

  def test_MatEye
    a = CVFFI::Mat.eye( 5, :CV_8U )

    a.each_with_indices { |d, i,j|
      assert_equal ( i==j ? 1 : 0 ),  d
    }
  end

  def test_resize
    img = TestSetup::test_image

    mat = img.to_Mat

    smaller = mat.resize( [640,480] )

    p smaller

    TestSetup::save_image( "smaller.jpg",  smaller)
  end
end
