
require 'opencv-ffi-wrappers/imgproc/features'

module CVFFI
  module ColorInvariance
    extend NiceFFI::Library
    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )

    load_library("cvffi", pathset)

    enum :cvColorInvariance, [ :CV_COLOR_INVARIANCE_PASSTHROUGH, 0,
                               :CV_COLOR_INVARIANCE_RGB2GAUSSIAN_OPPONENT, 1,
                               :CV_COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT, 2,
                               :CV_COLOR_INVARIANCE_Gray2YB, 100,
                               :CV_COLOR_INVARIANCE_Gray2RG, 101]

    #  void cvCvtColorInvariants( const CvArr *srcarr, CvArr *dstarr, int code )
    attach_function :cvCvtColorInvariants, [ :pointer, :pointer, :int ], :void


    attach_function :cvGenerateSQuasiInvariant, [ :pointer, :pointer, :pointer ], :void

  #cvQuasiInvariantFeaturesToTrack( const Mat *_quasiX, const Mat *_quasiY, 
  #    CvPoint2D32f* _corners, int *_corner_count,
  #    double quality_level, double min_distance,
  #    const void* _maskImage, int block_size,
  #    int use_harris, double harris_k )
  attach_function :cvQuasiInvariantFeaturesToTrack, [ :pointer, :pointer, :pointer,
                                                   :pointer, :double, :double,
                                                   :pointer, :int, :double ], :void

  def self.quasiInvariantFeaturesToTrack( quasiX, quasiY, params = CVFFI::GoodFeaturesParams.new )

    max_corners = FFI::MemoryPointer.new :int
    max_corners.write_int params.max_corners
    corners = FFI::MemoryPointer.new( CVFFI::CvPoint2D32f, params.max_corners )

    cvQuasiInvariantFeaturesToTrack( quasiX.to_CvMat, quasiY.to_CvMat, 
                                    corners, max_corners, 
                                 params.quality_level, params.min_distance, params.mask,
                                 params.use_harris ? 1 : 0, params.k )

    max_corners = max_corners.read_int 
    puts max_corners

    points = Array.new( max_corners ) {|i|
      CVFFI::CvPoint2D32f.new( corners + CVFFI::CvPoint2D32f.size * i )
    }
  end

 
  end
end

