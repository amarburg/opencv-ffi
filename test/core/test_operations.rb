
require 'test/setup'
require 'opencv-ffi/core'
require 'opencv-ffi/highgui'


class TestCoreOperations < Test::Unit::TestCase

    WHITE  = CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )
    BLACK = CVFFI::CvScalar.new( {:w=>0, :x=>0, :y=>0, :z=>0} )

  def setup
    @center = CVFFI::CvPoint.new( :x => 50, :y => 50 )
    @radius = 50
  end


  def assert_color_at_point( img, point, color )
    c = CVFFI::cvGet2D( img, point.x, point.y )
    assert_equal color.w, c.w, "First channel mismatch"
    assert_equal color.x, c.x, "Second channel mismatch" if img.nChannels > 1
    assert_equal color.y, c.y, "Third channel mismatch"  if img.nChannels > 2
    assert_equal color.z, c.z, "Fourth channel mismatch" if img.nChannels > 3
  end
  
  def test_cvReleaseImage
    imgOne = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>100, :height=>100 ), 8, 1 )
    CVFFI::cvReleaseImage( imgOne )
  end


  def test_imageOperations
    imgOne = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>100, :height=>100 ), 8, 1 )
    CVFFI::cvSet( imgOne, BLACK, nil )

    imgTwo = CVFFI::cvCloneImage( imgOne )

    assert_equal imgOne.nChannels, imgTwo.nChannels
    assert_equal imgOne.depth,     imgTwo.depth
    assert_equal imgOne.width,     imgTwo.width
    assert_equal imgOne.height,    imgTwo.height

    assert_color_at_point imgOne, @center, BLACK
    assert_color_at_point imgTwo, @center, BLACK

    # Draw a circle on one
    CVFFI::cvCircle( imgOne, @center, @radius, WHITE, -1, 8, 0 )

    assert_color_at_point imgOne, @center, WHITE
    assert_color_at_point imgTwo, @center, BLACK

    # Now copy
    CVFFI::cvCopy( imgOne, imgTwo, nil )

    assert_color_at_point imgOne, @center, WHITE
    assert_color_at_point imgTwo, @center, WHITE
  end

  def test_roiOperations
    imgOne = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>100, :height=>100 ), 8, 1 )
    CVFFI::cvSet( imgOne, BLACK, nil )
    CVFFI::cvCircle( imgOne, @center, @radius, WHITE, -1, 8, 0 )

    imgTwo = CVFFI::cvCreateImage( CVFFI::CvSize.new( :width=>200, :height=>200 ), 8, 1 )
    CVFFI::cvSet( imgTwo, BLACK, nil )

    0.upto(100) { |i|
      if i%25 == 0

        roi = CVFFI::CvRect.new( :width => 100, :height => 100, :x => i, :y => i )
        CVFFI::cvSetImageROI( imgTwo, roi )

        r = CVFFI::CvRect.new CVFFI::cvGetImageROI( imgTwo )

        assert_equal r.width, roi.width
        assert_equal r.height, roi.height
        assert_equal r.x, roi.x
        assert_equal r.y, roi.y

        CVFFI::cvCopy( imgOne, imgTwo, nil )

      end
    }

    CVFFI::cvResetImageROI( imgTwo )

    TestSetup::save_image( "test_roi", imgTwo )

  end

  def test_transpose
    m = CVFFI::cvCreateMat( 3,3, :CV_32F )
    CVFFI::cvSetZero( m )
    CVFFI::cvSetReal2D( m, 0, 2, 1.0 )

    assert_equal CVFFI::cvGetReal2D( m, 0, 2 ), 1.0
    assert_equal CVFFI::cvGetReal2D( m, 2, 0 ), 0.0

    t = CVFFI::cvCreateMat( 3,3, :CV_32F )
    CVFFI::cvTranspose( m, t )

    assert_equal CVFFI::cvGetReal2D( m, 0, 2 ), 1.0
    assert_equal CVFFI::cvGetReal2D( m, 2, 0 ), 0.0

    assert_equal CVFFI::cvGetReal2D( t, 0, 2 ), 0.0
    assert_equal CVFFI::cvGetReal2D( t, 2, 0 ), 1.0
  end

  def test_solve_cubic
    c = CVFFI::cvCreateMat( 1,4, :CV_32F )
    r = CVFFI::cvCreateMat( 1,3, :CV_32F )
    CVFFI::cvSetZero( r )

    # The roots of x^3 - 6x^2 + 11x - 6
    # are 1,2,3
    [1,-6,11,-6].each_with_index { |x,i|
      CVFFI::cvSetReal1D(c,i,x)
    }

    CVFFI::cvSolveCubic( c, r )

    # For siplicity, dump to an array I can sort
    r = Array.new(3) { |i|
      CVFFI::cvGetReal1D(r,i)
    }.sort
    
    3.times { |i|
      assert_in_delta i+1, r[i], 1e-06
    }
  end




end
