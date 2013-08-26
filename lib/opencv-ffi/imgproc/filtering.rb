require 'opencv-ffi/imgproc/library'

module CVFFI

  enum :cvSmoothCodes, [ :CV_BLUR_NO_SCALE, 0,
                         :CV_BLUR, 1,
                         :CV_GAUSSIAN, 2,
                         :CV_MEDIAN, 3,
                         :CV_BILATERAL, 4 ]

  attach_function :cvSmooth, [ :pointer, :pointer, :int, :int, :int, :double, :double], :void
  
  attach_function :cvSobelReal, :cvSobel, [:pointer, :pointer, :int, :int, :int ], :void
  def cvSobel( src, dst, xorder, yorder, apertureSize = 3 )
    cvSobelReal( src, dst, xorder, yorder, apertureSize )
  end

end
