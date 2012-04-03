
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
      CVFFI::IplImage.new CVFFI::cvCloneImage( self )
    end

    def twin( *opts )
      depth,nChannels = if opts[0].is_a? Hash
                          opts = opts.pop
                          [opts[:depth], opts[:channels]]
                        else
                          opts
                        end

      depth ||= self.depth
      nChannels ||= self.nChannels
      CVFFI::IplImage.new CVFFI::cvCreateImage( self.image_size.to_CvSize, depth, nChannels )
    end

    def split
      nchannels = self.nChannels
      out = Array.new( nchannels ) { |i| CVFFI::cvCreateImage( self.image_size.to_CvSize, depth, 1 ) }
      
      CVFFI::cvSplit( self, out[0], out[1], out[2], out[3] );
      out[0,nchannels]
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

    def save(fname)
      CVFFI::cvSaveImage( fname, self )
    end


    module ClassMethods
      def load( fname, color = true )
        CVFFI::cvLoadImage( fname, color ? CV_LOAD_IMAGE_COLOR : CV_LOAD_IMAGE_GRAYSCALE )
      end
    end

    def self.included( base )
      base.extend( ClassMethods)
    end
  end

  class IplImage
    include IplImageFunctions
  end


end
