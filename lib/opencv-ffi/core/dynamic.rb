
require 'core/library'
require 'core/types'

module CVFFI

  attach_function :cvCreateMemStorage, [ :int ], CvMemStorage.typed_pointer

  attach_function :cvGetSeqElem, [ :pointer, :int ], :pointer

end
