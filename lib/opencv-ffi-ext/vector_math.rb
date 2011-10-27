
require 'nice-ffi'
require 'opencv-ffi-wrappers/vectors'

module CVFFI
  module VectorMath
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/opencv-ffi/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi", pathset)

    
    module NativeVectors
      def self.included( base )
        base.extend( ClassMethods)
      end

      module ClassMethods
        def define_vector( type, length, name = nil )
          name = name || "#{type}_#{length}_vector"
          class_eval <<-eos
          class #{name} < NiceFFI::Struct
              layout :d, [:#{type}, #{length}]
              def length; #{length}; end
          end
          eos
          name
        end
      end

      class ScalarVector

        def define_vector( type, length, name = nil )
          name = name || "Auto_#{type}_#{length}_vector"
          instance_eval <<-eos
          class #{name} < NiceFFI::Struct
              layout :d, [:#{type}, #{length}]
              def length; #{length}; end
          end
          eos
          name
        end

        attr_accessor :data
        def initialize( type, length )
          name = define_vector( type, length )
          instance_eval "@data = #{name}.new '\0'"
        end

        def [](i)
          @data.d[i]
        end

        def []=(i,b)
          @data.d[i] = b
        end

        def as_ScalarArray
          ScalarArray.new( len: @data.length,
                           data: @data )
        end
        alias :to_c :as_ScalarArray

      end
    end
        


    class UcharArray < NiceFFI::Struct
      layout :len, :uint,
             :data, :pointer
    end

    class ScalarArray < NiceFFI::Struct
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


