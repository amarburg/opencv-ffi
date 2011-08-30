
require 'nice-ffi'

module CVFFI
  extend NiceFFI::Library

  load_library("opencv_core")

  class CvMat < NiceFFI::Struct
    layout :type, :int,
           :step, :int,
           :refcount, :pointer,
           :hdr_refcount, :int,
           :data, :pointer,
           :height, :int,
           :width, :int

    hidden :refcount, :hdr_refcount
  end

  class CvRect < NiceFFI::Struct
    layout :x, :int,
           :y, :int,
           :width, :int,
           :height, :int
  end

  class CvSize < NiceFFI::Struct
    layout :width, :int,
           :height, :int
  end

  class CvSize2D32f < NiceFFI::Struct
    layout :width, :float,
           :height, :float
  end

  class CvSize2D64f < NiceFFI::Struct
    layout :width, :double,
           :height, :double
  end

  class CvPoint < NiceFFI::Struct
    layout :x, :int,
           :y, :int
  end

  class CvPoint2D32f < NiceFFI::Struct
    layout :x, :float,
           :y, :float
  end

  class CvPoint2D64f < NiceFFI::Struct
    layout :x, :double,
           :y, :double
  end
end
