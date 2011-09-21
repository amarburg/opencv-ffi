require 'nice-ffi'

module CVFFI
  module FAST
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/fast/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi_fast", pathset)

    class Xy < NiceFFI::Struct
      layout :x, :int,
        :y, :int
    end

    # Leave result as pointer, not Xy.typed_pointer as it makes it easier to deference
    # it to an array of Xy

    def self.fast_detect_function( sz )
      attach_function "fast#{sz}_detect".to_sym, [ :pointer, :int, :int, :int, :int, :pointer ], :pointer
    end

    fast_detect_function 9
    fast_detect_function 10
    fast_detect_function 11
    fast_detect_function 12


  end
end
