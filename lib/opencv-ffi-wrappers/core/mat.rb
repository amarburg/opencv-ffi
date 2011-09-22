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
        at_f(i,j)
      }
    end

    # This is somewhat awkward because the FFI::Struct-iness of
    # CvMat uses the Array-like API calls (at, [], size, etc)
    def at_f(i,j)
      CVFFI::cvGetReal2D( self, i, j )
    end

    def clone
      CVFFI::cvCloneMat( self )
    end

    def mat_size
      CVFFI::CvSize.new( :width => self.width, :height => self.height ) 
    end

    def twin
      CVFFI::cvCreateMat( self.height, self.width, self.type )
    end

    def transpose
      a = twin
      CVFFI::cvTranspose( self, a )
      a
    end

    def zero
      CVFFI::cvSetZero( self )
    end
  end

  class CvMat
    include CvMatFunctions
  end
end
