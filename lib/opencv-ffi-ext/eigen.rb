
require 'opencv-ffi'
require 'opencv-ffi-wrappers'

module CVFFI
  module Eigen
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/eigen/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi_eigen", pathset)


    ##--- SVD bits ---
    class EigenSvdResults < NiceFFI::Struct
      layout :D, CvMat.typed_pointer,
        :U, CvMat.typed_pointer,
        :V, CvMat.typed_pointer
    end

    attach_function :eigenSvdWithCvMat, [:pointer, :pointer, :uchar], :void

    def self.svd( a, opts = {} )
      thin = opts[:thin] ? 1 : 0

      results = EigenSvdResults.new '\0'
      eigenSvdWithCvMat( a.to_CvMat, results, thin )

      [ results.U, results.D, results.V ]
    end


    ##--- Polynomial solver bits --
    class Eigen7d <NiceFFI::Struct
      layout :a, :double,
             :b, :double,
             :c, :double,
             :d, :double,
             :e, :double,
             :f, :double,
             :g, :double
    end

    class Eigen6d < NiceFFI::Struct
      layout :a, :double,
             :b, :double,
             :c, :double,
             :d, :double,
             :e, :double,
             :f, :double
    end

    attach_function :eigenPoly6Solver, [Eigen7d.by_value], Eigen6d.by_value

    def self.polySolver( a )

      case a.length
      when 7  then
        coeffs = Eigen7d.new( a )
        answer = eigenPoly6Solver( coeffs )
      else
        raise "Can't solve polynomial with #{a.length} coefficients"
      end

      answer.to_ary
    end
  end
end

