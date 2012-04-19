

require 'opencv-ffi/core/types'
require 'opencv-ffi/imgproc/library'

module CVFFI

  attach_function :cvGetAffineTransform, [ :pointer, :pointer, :pointer ], CvMat.typed_pointer

  @cvWarpFlags = enum :cvWarpFlags, [ :CV_INTER_LINEAR, 1,
                                      :CV_WARP_FILL_OUTLIERS, 8,
                                      :CV_WARP_INVERSE_MAP, 16  ]
  
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
  attach_function :cvWarpAffineReal, :cvWarpAffine, [ :pointer, :pointer, :pointer, :int, CvScalar.by_value ], :void

  def self.cvWarpAffine( src, dst, map_matrix, flags = nil, fillval = nil )
    flags ||= @cvWarpFlags[:CV_INTER_LINEAR]+@cvWarpFlags[:CV_WARP_FILL_OUTLIERS]
    fillval ||= CVFFI::CvScalar.new( [0,0,0,0] )

    cvWarpAffineReal( src,dst,map_matrix,flags,fillval )
  end


  attach_function :cvWarpPerspectiveReal, :cvWarpPerspective, [ :pointer, :pointer, :pointer, :int, CvScalar.by_value], :void
  def self.cvWarpPerspective( src, dst, map_matrix, flags = nil, fillval = nil )
    flags ||= @cvWarpFlags[:CV_INTER_LINEAR]+@cvWarpFlags[:CV_WARP_FILL_OUTLIERS]
    fillval ||= CVFFI::CvScalar.new( [0,0,0,0] )

    cvWarpPerspectiveReal( src, dst, map_matrix, flags, fillval )
  end

  # CVAPI(CvMat*)  cv2DRotationMatrix( CvPoint2D32f center, 
  #                                    double angle,
  #                                    double scale, 
  #                                    CvMat* map_matrix );
  attach_function :cv2DRotationMatrix, [ CvPoint2D32f.by_value, :double, :double, :pointer ], :void
end
