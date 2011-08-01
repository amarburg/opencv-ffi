
require 'opencv-ffi/core'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_imgproc")

end
