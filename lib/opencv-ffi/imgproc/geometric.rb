

require 'imgproc/library'
require 'core/types'

module CVFFI

  # CVAPI(void)  cvWarpAffine( const CvArr* src, 
  #                            CvArr* dst, 
  #                            const CvMat* map_matrix,
  #                            int flags CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS),
  #                            CvScalar fillval CV_DEFAULT(cvScalarAll(0)) );
  attach_function cvWarpAffine( :pointer, :pointer, :pointer ), :void

end
