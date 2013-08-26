

module CVFFI

  class Mat

    def sobel( xorder, yorder, apertureSize = 3 )
      dst = twin
      cvSobel( self.to_CvMat, dst.to_CvMat, xorder, yorder, apertureSize )

      dst
    end
  end
end
