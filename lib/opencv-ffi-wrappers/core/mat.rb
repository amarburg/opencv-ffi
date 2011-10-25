require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'

require 'matrix'


# Monkey with Matrix and Vector's coercion functions
class Vector
  alias :coerce_orig :coerce
  def coerce(other)
    case other
    when CvMat
      nil
    else
      coerce_orig(other)
    end
  end
end

class ScalarMatrix
  attr_accessor :column_size
  attr_accessor :data

  def initialize(data)
    @data = data
    raise "Hm, not array data" unless data.is_a? Array
    raise "Hm, not array-in-array data" unless data[0].is_a? Array

    @data.each { |d| d.map! { |d| d = d.to_i } }

    @column_size = data[0].length
    data.each_with_index { |d,idx|
      raise "Hm, row #{idx} not the same length as others" unless d.length == @column_size
    }
  end

  def self.rows(  data )
    ScalarMatrix.new( data )
  end

  def row_size
    @data.length
  end

  def check_bounds(x,y)
    raise "x too small" if x < 0
    raise "x too large" if x >= column_size
    raise "y too small" if y < 0
    raise "y too large" if y >= row_size
  end

  def [](x,y)
    check_bounds(x,y)
    @data[y][x]
  end

  def []=(x,y,d)
    check_bounds(x,y)
    @data[y][x] = d.to_i
  end

  def to_CvMat( opts = {} )
    type = opts[:type] || :CV_32F
    a = CVFFI::cvCreateMat( row_size, column_size, type )
    @data.each_with_index { |d,j|
      d.each_with_index { |d,i|
        a.set_f( j,i,d )
      }
    }
    a
  end

  def to_a
    @data
  end

  def ==(b)
    column_size == b.column_size and row_size == b.row_size and data == b.data

  end

  def l2distance(b)
    # Pure ruby, for now
    me = @data.flatten
    them = b.data.flatten

    raise "Hm, trying to compute distance between two ScalarMatrices of different sizes" unless me.length == them.length
    me.inject_with_index(0.0) { |x,d,i| x + (d-them[i])**2 }
  end
end


module CVFFI

  module CvMatFunctions
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # This is the somewhat funny Matrix format for coerce
    # which returns the template class as well as the coerced version
    # of the matrix
    def coerce( other )
            case other
                     when Matrix 
                       [other, to_Matrix]
                     when Vector 
                       [other, to_Vector]
                     else
                       raise TypeError, "#{self.class} can't be coerced into #{other.class}, fool"
                     end
          end


    def to_CvMat( opt = {} )
      if opt[:type]
        raise "Need to convert CvMat types" if opt[:type] != type
      end
      self
    end

    def to_Matrix
      Matrix.build( height, width ) { |i,j|
        at_f(i,j)
      }
    end

    def to_ScalarMatrix
      ScalarMatrix.rows Array.new( height ) { |y|
        Array.new( width ) { |x|
          d = CVFFI::cvGet2D( self, y,x )
          d.w
        }
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
      Vector[*a]
    end

    def to_a
      to_Vector.to_a
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

    def print( opts = nil )

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
