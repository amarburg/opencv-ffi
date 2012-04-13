
require 'opencv-ffi-wrappers/core/mat'
require 'opencv-ffi-wrappers/core/size'
require 'opencv-ffi-wrappers/core/point'
require 'opencv-ffi-wrappers/core/iplimage'
require 'opencv-ffi-wrappers/core/scalar'
require 'opencv-ffi-wrappers/core/rect'
require 'opencv-ffi-wrappers/core/misc_draw'
require 'opencv-ffi-wrappers/core/sequence'

require 'opencv-ffi-wrappers/matrix'

require 'opencv-ffi/core'


module CVFFI
  def self.solveCubic( coeffs )
    roots = CVFFI::CvMat.new CVFFI::cvCreateMat( 1,3, :CV_32F )

    CVFFI::cvSolveCubic( coeffs.to_CvMat, roots )

    roots.coerce( coeffs )[1]
  end

  def self.avgSdv( mat, mask = nil )
    mean = CVFFI::CvScalar.new
    stddev = CVFFI::CvScalar.new

    CVFFI::cvAvgSdv( mat.to_CvMat, mean, stddev, mask.to_CvMat )

    [ mean.w, stddev.w ]
  end

  def self.avg( mat, mask = nil )
    mean = CVFFI::cvAvg( mat.to_CvMat, mask.to_CvMat )
    mean.w
  end

end

