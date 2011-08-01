
require 'opencv-ffi/core'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_highgui")

  CV_LOAD_IMAGE_UNCHANGED  =-1
  CV_LOAD_IMAGE_GRAYSCALE  = 0
  CV_LOAD_IMAGE_COLOR      = 1
  attach_function :cvLoadImageM, [ :string, :int ], CvMat.typed_pointer

  attach_function :cvSaveImage, [ :string, :pointer ], :int

end
