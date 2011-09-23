require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'

require 'matrix'

module CVFFI

  module CvMatFunctions
    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_CvMat
      self
    end

    def to_Matrix
      Matrix.build( height, width ) { |i,j|
        at_f(i,j)
      }
    end

    def to_Vector
      to_Matrix if height > 1 and width > 1
      a = []
      if height == 1
         a = Array.new( width ) { |i| at_f(0,i) } 
      else
        a = Array.new( height ) { |i| at_f(i,0) }
      end
      Vector.elements(a)
    end

    # This is somewhat awkward because the FFI::Struct-iness of
    # CvMat uses the Array-like API calls (at, [], size, etc)
    def at_f(i,j)
      CVFFI::cvGetReal2D( self, i, j )
    end

    def set_f( i,j, f )
      CVFFI::cvSetReal2D( self, i, j, f )
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


    module ClassMethods 
      def eye( x, type = :CV_32F )
        a = CVFFI::cvCreateMat( x, x, type )
        CVFFI::cvSetIdentity( a, CVFFI::CvScalar.new( :w => 1, :x => 1, :y => 1, :z => 1 ) )
        a
      end
    end


  end

  class CvMat
    include CvMatFunctions
  end
end
