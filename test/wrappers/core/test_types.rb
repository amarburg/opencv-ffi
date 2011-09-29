
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi-wrappers/core'

class TestCoreTypesWrappers < Test::Unit::TestCase

  def test_cvSizeWrappers
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

    r = p.to_CvSize
    assert_equal p,r

    q = p.to_CvSize2D32f
    assert_in_delta 3.0, q.width, TestSetup::EPSILON
    assert_in_delta 2.0, q.height, TestSetup::EPSILON
  end

  def test_point
    p = CVFFI::Point.new( 4.0, 5.0 )
    assert_equal 4.0, p.x
    assert_equal 5.0, p.y

    q = p.to_CvPoint
    assert_equal 4.0, q.x
    assert_equal 5.0, q.y

    a = p.to_a
    assert a.is_a?(Array)
    assert_equal 3, a.length
    assert_equal 4.0, a[0]
    assert_equal 5.0, a[1]
    assert_equal 1.0, a[2]

    a = p.to_a(false)
    assert a.is_a?(Array)
    assert_equal 2, a.length
    assert_equal 4.0, a[0]
    assert_equal 5.0, a[1]

  end

  def test_size
    p = CVFFI::Size.new( [4.0, 5.0] )

    assert_equal 4.0, p.width
    assert_equal 5.0, p.height

    assert_in_delta 20.0, p.area, TestSetup::EPSILON

    q = p.to_CvSize2D32f
    assert q.is_a?( CVFFI::CvSize2D32f )
    assert_in_delta 4.0, q.width, TestSetup::EPSILON
    assert_in_delta 5.0, q.height, TestSetup::EPSILON

    r = CVFFI::Size.new p
    assert_equal 4.0, r.width
    assert_equal 5.0, r.height

    s = p/2.0
    assert_equal 2.0, s.width
    assert_equal 2.5, s.height

    p *= 2.0
    assert_equal 8.0, p.width
    assert_equal 10.0, p.height
  end

  def test_point
    p = CVFFI::Point.new( 10.0, 0.0 )

    assert_equal 10.0, p.x
    assert_equal  0.0, p.y

    q = p.rotate( 0.0 )
    assert_equal 10.0, q.x
    assert_equal  0.0, q.y

    q = p.rotate( Math::PI/2.0 )
    assert_in_delta 0.0, q.x, TestSetup::EPSILON
    assert_in_delta 10.0, q.y, TestSetup::EPSILON
  end

  def test_iplimage
    img = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>100, :height=>100 ), 8, 1 )

    size = img.image_size

    assert_not_nil size
    assert_equal 100, size.width
    assert_equal 100, size.height

    clone = img.clone


    twin = img.twin
    assert_equal img.image_size, twin.image_size
    assert_equal img.depth,      twin.depth
    assert_equal img.nChannels,  twin.nChannels

  end

  def test_rect
    r = CVFFI::Rect.new( :center => CVFFI::Point.new( 0.0, 0.0 ),
                        :size   => CVFFI::Size.new(  10.0, 10.0 ) )

    assert_equal -5.0, r.origin.x
    assert_equal -5.0, r.origin.y
    assert_equal 10.0, r.size.width
    assert_equal 10.0, r.size.height

    cv = r.to_CvRect

    assert_equal -5.0, cv.x
    assert_equal -5.0, cv.y
    assert_equal 10.0, cv.width
    assert_equal 10.0, cv.height
  end

  def test_mat
    m = CVFFI::CvMat.eye( 3 )

    3.times { |i|
      3.times { |j|
assert_equal m.at_f(i,j), ( i==j ? 1.0 : 0.0 )
      }
    }

    mat = m.to_Matrix
    assert_not_nil mat
    assert_equal  mat[0,0], 1.0
    assert_equal mat[0,0], m.at_f(0,0)

    r = m.clone
    assert_equal m.height, r.height
    assert_equal m.width, r.width
    assert_equal m.type, r.type
    assert_equal m.at_f(0,0), r.at_f(0,0)

    q = m.twin
    assert_equal m.height, q.height
    assert_equal m.width, q.width
    assert_equal m.type, q.type
    assert_not_equal m.at_f(0,0), q.at_f(0,0)
  end

  def test_vector
    m = CVFFI::cvCreateMat( 1, 5, :CV_32F )
    n = CVFFI::cvCreateMat( 5, 1, :CV_32F )

    5.times { |i|
      m.set_f(0,i,i)
      n.set_f(i,0,i)
    }

    mv = m.to_Vector
    nv = n.to_Vector

    5.times { |i|
      assert_equal i, mv[i]
      assert_equal i, nv[i]
    }
  end

  def test_mat_transpose
    m = CVFFI::cvCreateMat( 3,3,:CV_32F)
    m.zero
    m.set_f( 0, 2, 1.0 )

    assert_equal m.at_f( 0, 2 ), 1.0
    assert_equal m.at_f( 2, 0 ), 0.0

    t = m.transpose
    assert_equal m.at_f( 0, 2 ), 1.0
    assert_equal m.at_f( 2, 0 ), 0.0

    assert_equal t.at_f( 0, 2 ), 0.0
    assert_equal t.at_f( 2, 0 ), 1.0
  end

  def test_mat_coercion
    a = Matrix.rows( [ [ 1,0,0 ], [0,2,0], [0,0,3] ] )
    b = CVFFI::CvMat.eye( 3 )

    c = nil
    assert_nothing_raised {
      c = a*b
    }
    assert c.is_a?(Matrix)
    assert_equal 1, c[0,0]
    assert_equal 2, c[1,1]
    assert_equal 3, c[2,2]
  end

  def test_scalar
    # Test each expected initializer pattern
    # Default ordering is BGRA
    [ CVFFI::Scalar.new( 1,2,0,4 ),
      CVFFI::Scalar.new( :w => 1, :x => 2, :z => 4),
      CVFFI::Scalar.new( :A => 4, :g => 2, :B => 1) ].each { |m|

      [ [1,2,0,4], [:w,:x,:y,:z], [:B,:G,:R,:A], [:b,:g,:r,:a ] ].transpose.each { |i,j,k,p|
        assert_equal i, m[j], "m[:#{j.to_s}] != #{i} for #{m.to_s}"
        assert_equal i, m[k], "m[:#{k.to_s}] != #{i} for #{m.to_s}"
        assert_equal i, m[p], "m[:#{p.to_s}] != #{i} for #{m.to_s}"
      }
    }


  end
end
