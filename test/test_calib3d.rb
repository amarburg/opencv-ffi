
require 'test/setup'
require 'opencv-ffi/calib3d'
require 'opencv-ffi-wrappers/misc'
require 'find'

recursive_test 'calib3d'

class TestCalib3d < Test::Unit::TestCase

  def test_cvFundamentalMatrix
    # First, the "verbatim" approach, with some rubbish data

    points = 20
    pointsOne = CVFFI::cvCreateMat( points, 2, :CV_32F )
    pointsTwo = CVFFI::cvCreateMat( points, 2, :CV_32F )

    points.times { |i|
      u = CVFFI::CvScalar.new( :w => rand, :x => 0.0, :y => 0.0, :z => 0.0 )
      v = CVFFI::CvScalar.new( :w => rand, :x => 0.0, :y => 0.0, :z => 0.0 )
      w = CVFFI::CvScalar.new( :w => rand, :x => 0.0, :y => 0.0, :z => 0.0 )
      x = CVFFI::CvScalar.new( :w => rand, :x => 0.0, :y => 0.0, :z => 0.0 )
      CVFFI::cvSet2D( pointsOne, i, 0, u )
      CVFFI::cvSet2D( pointsOne, i, 1, v )
      CVFFI::cvSet2D( pointsTwo, i, 0, w )
      CVFFI::cvSet2D( pointsTwo, i, 1, x )
    }

    fundamental = CVFFI::cvCreateMat( 3,3, :CV_32F )
    status  = CVFFI::cvCreateMat( points, 1, :CV_8U )

    result = CVFFI::cvFindFundamentalMat( pointsOne, pointsTwo, fundamental, :CV_FM_RANSAC, 1.0, 0.99, status )

    CVFFI::print_matrix fundamental, {:caption=>"Fundamental = "}
    #CVFFI::print_matrix status, {:caption=>"Status = "}

  end
end
