
require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

module CVFFI

  #
  # C SURF interface removed from 2.4 (?)
  # Restructure and move to opencv-ffi-ext??
  #
  class CvSURFParams < NiceFFI::Struct
    layout :extended,      :int,
           :upright,       :int,
           :hessianThreshold, :double,
           :nOctaves,      :int,
           :nOctaveLayers, :int
  end

  class CvSURFPoint < NiceFFI::Struct
    layout :pt, CvPoint2D32f,
           :laplacian, :int,
           :size, :int,
           :dir,  :float,
           :hessian, :float 
  end

  # CVAPI(void) cvExtractSURF( const CvArr* img, 
  #                            const CvArr* mask,
  #                            CvSeq** keypoints, 
  #                            CvSeq** descriptors,
  #                            CvMemStorage* storage, 
  #                            CvSURFParams params, 
  #                            int useProvidedKeyPts CV_DEFAULT(0)  );

#  attach_function :cvExtractSURF, [ :pointer, :pointer, 
#                                    :pointer, :pointer, 
#                                    :pointer, 
#                                    CvSURFParams.by_value, :cvBoolean ], :void
#
end
