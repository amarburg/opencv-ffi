
require 'nice-ffi'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_core")

  class CvMat < NiceFFI::Struct
    layout :type, :int,
           :step, :int,
           :refcount, :pointer,
           :hdr_refcount, :int,
           :data, :pointer,
           :height, :int,
           :width, :int

    hidden :refcount, :hdr_refcount
  end

end
