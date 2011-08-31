require 'core'

module CVFFI

  class CvSizeBase < NiceFFI::Struct
  end

  class CvSize < CvSizeBase
    layout :width, :int,
           :height, :int
  end

  class CvSize2D32f < CvSizeBase
    layout :width, :float,
           :height, :float
  end

  class CvSize2D64f < CvSizeBase
    layout :width, :double,
           :height, :double
  end
end
