
require 'nice-ffi'
require 'opencv-ffi-wrappers/vectors'

module CVFFI
  module VectorMath
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    class UcharArray < NiceFFI::Struct
      layout :len, :uint,
             :data, :pointer
    end

    attach_function :L2distance_32f, [:pointer, :pointer, :int], :float
    attach_function :realL2distance_8u, :L2distance_8u, [UcharArray.by_value, UcharArray.by_value], :float

    def self.L2distance( a,b, len = nil)
      len ||= a.length
      L2distance_32f( a, b, len )
    end

    def self.uchar_array_cast( a )
      case a
      when UcharArray
        a
      else
        d = FFI::MemoryPointer.new :uint8, a.length
        d.write_array_of_uint8( a )
        #d.write_array_of_uint8( a.map{ |a| [[ a.to_i, 0 ].max, 255].min }  ) 
        UcharArray.new( len: a.length, data: d )
      #else
      #  raise "Can't convert type #{a} to a uchar_array"
      end
    end

    def self.L2distance_8u( a,b )
      ## Allow for some dynamic repacking
      raise "Arrays not same length" unless a.length == b.length
      a = uchar_array_cast( a )
      b = uchar_array_cast( b ) 

      realL2distance_8u( a, b )
    end
  end


end


