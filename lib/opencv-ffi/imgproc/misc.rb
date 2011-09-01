
require 'imgproc/library'

module CVFFI

  enum :cvCvtCodes, [ :CV_RGB2RGB, 0,
                     :CV_BGR2BGRA, 0,
                     :CV_RGBA2RGB,
                     :CV_BGRA2BGR, 1,
                     :CV_RGB2BGRA,
                     :CV_BGR2RGBA, 2,
                     :CV_RGBA2BGR,
                     :CV_BGRA2RGB, 3,
                     :CV_BGR2RGB,
                     :CV_RGB2BGR, 4,
                     :CV_BGRA2RGBA,
                     :CV_RGBA2BGRA, 5,
                     :CV_BGR2GRAY,
                     :CV_RGB2GRAY,
                     :CV_GRAY2BGR,
                     :CV_GRAY2RGB, 8,
                     :CV_GRAY2BGRA,
                     :CV_GRAY2RGBA, 9,
                     :CV_BGRA2GRAY,
                     :CV_RGBA2GRAYa ]

  attach_function :cvCvtColor, [ :pointer, :pointer, :cvCvtCodes ], :void


  enum :cvInterpolation, [ :CV_INTER_NN, 0,
                           :CV_INTER_LINEAR,
                           :CV_INTER_CUBIC,
                           :CV_INTER_AREA,
                           :CV_INTER_LANCZOS4 ]

  attach_function :cvResize, [ :pointer, :pointer, :cvInterpolation ], :void 

end
