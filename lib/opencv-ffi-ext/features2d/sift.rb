

require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

module CVFFI
  extend NiceFFI::Library

  libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
  pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
  load_library("cvffi", pathset)

  class CvSIFTParams < NiceFFI::Struct
    layout :nOctaves, :int,
           :nOctaveLayers, :int,
           :threshold, :double,
           :edgeThreshold, :double,
           :magnification, :double
  end

  ## void cvSIFTDetect( const CvArr *img, const CvArr *mask, 
  #                     CvSeq **keypoints, CvMemStorage *storage, 
  #                     CvSIFTParams_t params )
  attach_function :cvSIFTDetect, [ :pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void 

end
