

require 'opencv-ffi'

module CVFFI

  # Might be the simplest way to do this
  class GetAffineTransformPoints < NiceFFI::Struct
    layout :a, [ CvPoint2D32f, 3 ]
  end

  def self.getAffineTransform( src, dst )
    result = CVFFI::cvCreateMat( 2, 3, :CV_32F )

    srcPts = GetAffineTransformPoints.new '\0'
    dstPts = GetAffineTransformPoints.new '\0'

    0.upto(2) { |i|
      srcPts.a[i].x = src[i].x
      srcPts.a[i].y = src[i].y
      dstPts.a[i].x = dst[i].x
      dstPts.a[i].y = dst[i].y
    }

    CVFFI::cvGetAffineTransform( srcPts, dstPts, result )
  end
end
