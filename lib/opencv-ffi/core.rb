## An omnibus file which brings in all the core/* sub-files

require 'core/core'
require 'core/size'

module CVFFI

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

