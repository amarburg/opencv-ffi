require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

module CVFFI

  class CvStarDetectorParams < NiceFFI::Struct
    layout :maxSize, :int,                 # maximal size of the features 
                                           # detected. The following
                                           # values of the parameter are supported:
                                           # 4, 6, 8, 11, 12, 16, 22, 23, 32, 45, 46, 64, 90, 128
           :responseThreshold, :int,       # threshold for the approximatd laplacian,
                                           # used to eliminate weak features
           :lineThresholdProjected, :int,  # another threshold for laplacian to
                                           # eliminate edges
           :lineThresholdBinarized, :int,  # another threshold for the feature
                                           # scale to eliminate edges
           :suppressNonmaxSize, :int       # linear size of a pixel neighborhood
                                           # for non-maxima suppression
  end

  class CvStarKeypoint < NiceFFI::Struct
    layout :pt, CvPoint,
           :size, :int,
           :response, :float
  end

  #  TODO: Function removed from Opencv 2.4?  Investigate.
  #attach_function :cvGetStarKeypoints, [ :pointer, :pointer, CvStarDetectorParams.by_value ], CvSeq.typed_pointer

end
