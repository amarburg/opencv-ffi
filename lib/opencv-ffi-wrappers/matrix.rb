
require_relative "core/mat"

class Matrix

  def to_Matrix
    self
  end

  # Painful but that's OK...
  def to_CvMat( opts = {} )
    type = opts[:type] || :CV_32F
    a = CVFFI::cvCreateMat( row_size, column_size, type )
    each_with_index { |e,i,j|
      a.set_f( i, j, e )
    }
    a
  end

  def to_Mat( opts = {} )
    Mat.new to_CvMat(opts)
  end

end

class Vector

  def to_Vector
    self
  end

  def to_CvMat( opts = {} )
    type = opts[:type] || :CV_32F
    a = CVFFI::cvCreateMat( size, 1,  type )
    size.times { |i|
      CVFFI::cvSetReal1D( a, i, element(i))
    }
    a
  end

  def to_Mat( opts = {} )
    Mat.new to_CvMat(opts)
  end
end

    
