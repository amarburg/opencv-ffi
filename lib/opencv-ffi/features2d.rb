
require 'opencv-ffi/core'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_features2d")

class CvSURFParams < NiceFFI::Struct
  layout :hessianThreshold, :double,
         :extended, :int

end

  attach_function :cvExtractSURF, [ :pointer, :pointer, :pointer, :pointer, :pointer, CvSURFParams ]

end
