
require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/map_with_index'


module CVFFI

  class FundamentalOrHomographyResults
    attr_accessor :status, :retval

    def initialize(  inliers, retval )
      @status = Array.new( inliers.height ) { |i| inliers.at_f( i, 0 ) > 0.0 ? true : false }
      @retval = retval
      status.extend MapWithIndex
    end

    def count_inliers
      count = status.reduce(0.0) { |m,obj|
        m += ( obj ) ? 1 : 0
      }
    end

    def inliers
      status.map_with_index { |s,i| s ? i : nil }.reject { |s| s.nil? }
    end

    def outliers
      status.map_with_index { |s,i| s ? nil : i }.reject { |s| s.nil? }
    end
  end

  class Fundamental < FundamentalOrHomographyResults
    attr_accessor :f

    def initialize( fin, inliers, retval )
      super(inliers, retval)
      @f = fin
    end
  end

  # This is a "thin" wrapper -- just some niceties
  def self.findFundamentalMat( points1, points2, 
                                method = :CV_FM_RANSAC, param1 = 3.0, param2 = 0.99 )

    fundamental = CVFFI::cvCreateMat( 3,3, :CV_32F )
    status = CVFFI::cvCreateMat( points1.height, 1, :CV_8U )

    ret = CVFFI::cvFindFundamentalMat( points1, points2, fundamental, method, param1, param2, status )

    if ret> 0
      Fundamental.new( fundamental, status, ret )
    else
      nil
    end
  end


  class Homography < FundamentalOrHomographyResults
    attr_accessor :h

    def initialize( h, status )
      super(status, 0)
      @h = h
    end
  end

  def self.findHomography( points1, points2, method = 0, reprojThreshold = 3 )
    homography = CVFFI::cvCreateMat( 3,3,:CV_32F)
    status = CVFFI::cvCreateMat( points1.height, 1, :CV_8U )

    CVFFI::cvFindHomography( points1, points2, homography, method, reprojThreshold, status )

    Homography.new( homography, status )
  end


end
