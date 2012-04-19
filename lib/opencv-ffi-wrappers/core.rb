
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

  ## Convenience wrappers around trickier CV functions
  def self.avg( mat, mask = nil )
    maskmat = mask ? mask.to_CvMat : nil
    mean = CVFFI::cvAvg( mat.to_CvMat, maskmat )
    mean.w
  end

  def self.avgSdv( mat, mask = nil )
    mean = CVFFI::CvScalar.new
    stddev = CVFFI::CvScalar.new
    maskmat = mask ? mask.to_CvMat : nil

    CVFFI::cvAvgSdv( mat.to_CvMat, mean, stddev, maskmat )

    [ mean.w, stddev.w ]
  end

  def self.getMat( mat )
    header = CVFFI::cvCreateMatHeader( 1,1, :CV_32F )
    CVFFI::cvGetMat( mat, header, nil, 0 )
  end

  def self.minMaxLoc( mat, mask = nil )
    maskmat = mask ? mask.to_CvMat : nil

    min_ptr = FFI::MemoryPointer.new :double
    max_ptr = FFI::MemoryPointer.new :double
    min_loc = CVFFI::CvPoint.new
    max_loc = CVFFI::CvPoint.new

    # Doesn't actually do loc at this point...
    CVFFI::cvMinMaxLoc( mat, min_ptr, max_ptr, min_loc, max_loc, maskmat )

    [ min_ptr.read_double, max_ptr.read_double, min_loc, max_loc ]
  end
end

