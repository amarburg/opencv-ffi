require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'

require 'matrix'

module CVFFI

  module CvMatFunctions
    def to_CvMat
      self
    end

    def to_Matrix
      Matrix.build( height, width ) { |i,j|
        CVFFI::cvGetReal2D( self, i,j )
      }
    end
  end

  class CvMat
    include CvMatFunctions
  end
end
