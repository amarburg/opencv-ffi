
require 'nice-ffi'
require 'opencv-ffi-wrappers/vectors'

module CVFFI
  module VectorMath
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    attach_function :L2distance_32f, [:pointer, :pointer, :int], :float

    def self.L2distance( a,b)
      L2distance_32f( a, b, a.nElem )
    end
  end
end


