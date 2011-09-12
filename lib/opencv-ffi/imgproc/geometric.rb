

require 'opencv-ffi/core/types'
require 'opencv-ffi/imgproc/library'

module CVFFI
  load_library("opencv_imgproc")

  attach_function :cvGetAffineTransform, [ :pointer, :pointer, :pointer ], CvMat.typed_pointer

  @cvWarpFlags = enum :cvWarpFlags, [ :CV_INTER_LINEAR, 1,
                                      :CV_WARP_FILL_OUTLIERS, 8 ]
  
  def self.cv_warp_flags_to_i( a )
    if @cvWarpFlags.symbols.include? a
      @cvWarpFlags[a] 
    else
      raise ::RuntimeError, "Undefined cvWarpFlags value #{a.inspect}"
    end
  end

  # CVAPI(void)  cvWarpAffine( const CvArr* src, 
  #                            CvArr* dst, 
  #                            const CvMat* map_matrix,
  #                            int flags CV_DEFAULT(CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS),
  #                            CvScalar fillval CV_DEFAULT(cvScalarAll(0)) );
  attach_function :cvWarpAffine, [ :pointer, :pointer, :pointer, :int, CvScalar.by_value ], :void

  # CVAPI(CvMat*)  cv2DRotationMatrix( CvPoint2D32f center, 
  #                                    double angle,
  #                                    double scale, 
  #                                    CvMat* map_matrix );
  attach_function :cv2DRotationMatrix, [ CvPoint2D32f.by_value, :double, :double, :pointer ], :void
end
