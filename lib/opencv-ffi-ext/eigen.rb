
require 'opencv-ffi'
require 'opencv-ffi-wrappers'

module CVFFI
  module Eigen
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/eigen/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )

    load_library("eigentocv", pathset)

    class EigenSvdResults < NiceFFI::Struct
      layout :W, CvMat.typed_pointer,
             :U, CvMat.typed_pointer,
             :V, CvMat.typed_pointer
    end


    attach_function :eigenSvdWithCvMat, [:pointer, :pointer], :void

    def self.svd( a )

      results = EigenSvdResults.new '\0'
      eigenSvdWithCvMat( a.to_CvMat, results )

      [ results.W, results.U, results.V ]
    end
  end
end

