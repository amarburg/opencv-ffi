
require 'opencv-ffi-wrappers'


module CVFFI

  class FundamentalResults
    attr_accessor :f, :status, :retval

    def initialize( f, status, retval )
      @f = f
      @status = status.to_Vector
      @retval = retval
    end

    def count_inliers
      a = status.to_a
      count = a.reduce(0.0) { |m,obj|
        m += ( obj > 0 ) ? 1 : 0
      }
    end
  end

  # This is a "thin" wrapper -- just some niceties
  def self.findFundamentalMat( points1, points2, method = :CV_FM_RANSAC, param1 = 3.0, param2 = 0.99 )
    fundamental = CVFFI::cvCreateMat( 3,3, :CV_32F )
    status = CVFFI::cvCreateMat( points1.height, 1, :CV_8U )

    ret = CVFFI::cvFindFundamentalMat( points1, points2, fundamental, method, param1, param2, status )

    if ret> 0
      FundamentalResults.new( fundamental, status, ret )
    else
      nil
    end
  end

  # CVAPI(int) cvFindFundamentalMat( const CvMat* points1, 
  #                                  const CvMat* points2,
  #                                  CvMat* fundamental_matrix,
  #                                  int method CV_DEFAULT(CV_FM_RANSAC),
  #                                  double param1 CV_DEFAULT(3.), 
  #                                  double param2 CV_DEFAULT(0.99),
  #                                  CvMat* status CV_DEFAULT(NULL) );
  attach_function :cvFindFundamentalMat, [ :pointer, :pointer, :pointer, 
                                           :int, :double, :double, :pointer ], :int

end
