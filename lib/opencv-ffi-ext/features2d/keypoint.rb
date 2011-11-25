
require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

module CVFFI

  class CvKeyPoint < NiceFFI::Struct
    layout :x, :float,
           :y, :float,
           :size, :float,
           :angle, :float,
           :response, :float,
           :octave, :int
  end

end
