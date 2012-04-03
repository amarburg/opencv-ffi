

module CVFFI
  module ColorInvariance
    extend NiceFFI::Library
    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )

    load_library("cvffi", pathset)

    enum :cvColorInvariance, [ :CV_COLOR_INVARIANCE_FOO, 0 ]

    #  void cvCvtColorInvariants( const CvArr *srcarr, CvArr *dstarr, int code )
    attach_function :cvCvtColorInvariants, [ :pointer, :pointer, :int ], :void
  end
end

