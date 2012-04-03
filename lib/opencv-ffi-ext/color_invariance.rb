

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

  end
end

