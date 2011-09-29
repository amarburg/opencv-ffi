
require 'nice-ffi'
require 'opencv-ffi/core'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_highgui", @pathset)

  CV_LOAD_IMAGE_UNCHANGED  =-1
  CV_LOAD_IMAGE_GRAYSCALE  = 0
  CV_LOAD_IMAGE_COLOR      = 1

  attach_function :cvLoadImageMFull, :cvLoadImageM, [ :string, :int ], CvMat.typed_pointer
  attach_function :cvLoadImageFull,  :cvLoadImage,  [ :string, :int ], IplImage.typed_pointer

  def self.cvLoadImageM( fname, color = CV_LOAD_IMAGE_COLOR )
    cvLoadImageMFull( fname, color )
  end

  def self.cvLoadImage( fname, color = CV_LOAD_IMAGE_COLOR )
    cvLoadImageFull( fname, color )
  end

  attach_function :cvSaveImageFull, :cvSaveImage, [ :string, :pointer, :pointer ], :int

  def self.cvSaveImage( name, ptr, params = nil )
    cvSaveImageFull( name, ptr, params )
  end

end
