
require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'

module CVFFI

  module IplImageFunctions
    def image_size
      Size.new( self.width, self.height )
    end

    def to_IplImage
      self
    end

    def clone
      CVFFI::cvCloneImage( self )
    end
  end

  class IplImage
    include IplImageFunctions
  end


end
