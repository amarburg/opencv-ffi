
require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'

module CVFFI
  load_library("opencv_calib3d")

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


