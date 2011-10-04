
class Matrix

  def to_Matrix
    self
  end

  # Painful but that's OK...
  def to_CvMat
    a = CVFFI::cvCreateMat( row_size, column_size, :CV_32F )
    each_with_index { |e,i,j|
      a.set_f( i, j, e )
    }
    a
  end

end

class Vector

  def to_Vector
    self
  end

  def to_CvMat
    a = CVFFI::cvCreateMat( size, 1, :CV_32F )
    size.times { |i|
      CVFFI::cvSetReal1D( a, i, element(i))
    }
    a
  end

end

    
