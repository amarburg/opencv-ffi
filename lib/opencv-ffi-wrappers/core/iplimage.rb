
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

    def twin
      CVFFI::cvCreateImage( self.image_size.to_CvSize, self.depth, self.nChannels )
    end

    def ensure_greyscale
      return self if nChannels == 1

      greyImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => height, 
                                                        :width => width }), 
                                                        :IPL_DEPTH_8U, 1 )
      CVFFI::cvCvtColor( self.to_IplImage, greyImg, :CV_BGR2GRAY )
      greyImg
    end
    alias :ensure_grayscale :ensure_greyscale
  end

  class IplImage
    include IplImageFunctions
  end


end
