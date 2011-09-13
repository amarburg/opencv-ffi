require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'

module CVFFI

  module CvMatFunctions

    def to_CvMat
      self
    end
  end

  class CvMat
    include CvMatFunctions
  end
end
