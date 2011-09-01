## An omnibus file which brings in all the core/* sub-files

require 'core'

module CVFFI

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

