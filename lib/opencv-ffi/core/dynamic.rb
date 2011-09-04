
require 'opencv-ffi/core/library'
require 'opencv-ffi/core/types'

module CVFFI

  attach_function :cvCreateMemStorage, [ :int ], CvMemStorage.typed_pointer
  attach_function :cvReleaseMemStorage, [:pointer], :void

  attach_function :cvGetSeqElem, [ :pointer, :int ], :pointer

end
