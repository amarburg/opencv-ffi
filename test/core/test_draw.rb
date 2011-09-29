

require 'test/setup'

class TestcvCircle < Test::Unit::TestCase

  def setup
    @img = TestSetup::test_image
  end


  def test_cvCircle
    center = CVFFI::CvPoint.new( :x => 500, :y => 500 )
    radius = 100
    color = CVFFI::CvScalar.new( {:w=>255, :x=>255, :y=>255, :z=>0} )

    CVFFI::cvCircle( @img, center, radius, color, -1, 8, 0 )

    # Spot check a few points within the radius
    pts = [ [500,500], [550,500], [450, 500] ]
    pts.each { |pt| 
      c = CVFFI::cvGet2D( @img, pt[0],pt[1] )

      assert_equal 255, c.w
      assert_equal 255, c.x
      assert_equal 255, c.y
      assert_equal 0, c.z
    }

    TestSetup::save_image( "test_cvCircle", @img )
  end

  def test_cvLine

    pointA = CVFFI::CvPoint.new( :x => 50, :y => 50 )
    pointB = CVFFI::CvPoint.new( :x => @img.width-50, :y => @img.height-50 )

    color = CVFFI::CvScalar.new( {:w=>255, :x=>0, :y=>255, :z=>0} )

    CVFFI::cvLine( @img, pointA, pointB, color, 10, 8, 0 )

    TestSetup::save_image( "text_cvLine", @img )
  end


end
