
require 'nice-ffi'
require 'opencv-ffi-wrappers/matcher'

module CVFFI
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    attach_function :computeReprojError, [:pointer, :pointer], :float
    attach_function :computeSetReprojError, [:pointer, :pointer], :void
end


