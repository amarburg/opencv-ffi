
require 'opencv-ffi/imgproc/library'

module CVFFI

  # CVAPI(void)  cvGoodFeaturesToTrack( const CvArr* image, CvArr* eig_image,
  #                                     CvArr* temp_image, CvPoint2D32f* corners,
  #                                     int* corner_count, double  quality_level,
  #                                     double  min_distance,
  #                                     const CvArr* mask CV_DEFAULT(NULL),
  #                                     int block_size CV_DEFAULT(3),
  #                                     int use_harris CV_DEFAULT(0),
  #                                     double k CV_DEFAULT(0.04) );
  attach_function :real_cvGoodFeaturesToTrack, :cvGoodFeaturesToTrack,
    [:pointer, :pointer, :pointer, :pointer, :pointer, :double, :double, :pointer, :int, :int, :double], :void

  # This version diverges from the OpenCV API because the original returns
  # an array of Point2D32f in corners ... this functions will provide
  # is as a return value.
  #
  # @param max_corners  The maximum number of corners to return
  # @return             An array of CvPoint2D32f giving the detected corners.
  def self.cvGoodFeaturesToTrack( image, eig_image, temp_image, max_corners, quality_level, min_distance, 
                             mask = nil, block_size = 3, use_harris = false, k = 0.04 )

    corner_count_ptr = FFI::MemoryPointer.new :int
    corner_count_ptr.write_int max_corners
    corner_ptr = FFI::MemoryPointer.new CvPoint2D32f, max_corners
    CVFFI::real_cvGoodFeaturesToTrack( image, eig_image, temp_image, corner_ptr, corner_count_ptr, quality_level, min_distance, mask, block_size, use_harris ? 1 : 0, k ) 

    corner_count = corner_count_ptr.read_int
    corners = Array.new( corner_count ) { |i|
      CvPoint2D32f.new( corner_ptr[i] )
    }
  end

end
