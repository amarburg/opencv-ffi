
class Float
  alias :add :+
  def +(b)
    case b
    when CVFFI::CvMat, CVFFI::Mat
      b + self
    else
      add( b )
    end
  end

  alias :subtract :-
  def -(b)
    case b
    when CVFFI::CvMat, CVFFI::Mat
      b.subtractReverse( self )
    else
      subtract( b ) 
    end
  end

  alias :multiply :*
  def *(b)
    case b
    when CVFFI::CvMat, CVFFI::Mat
      b * self
    else
      multiply(b)
    end
  end
end

class Array
  def merge( type = :CV_32FC3 )
    a = self
    a << nil while a.length < 4

    # TODO.  Automatically determine multichannel type based on types and number of arguments
    dst = CVFFI::Mat.new( a.first.rows, a.first.cols, type: type )
    args = a.first(4) + [dst]
    cvMerge( *args )
    dst
  end
end
