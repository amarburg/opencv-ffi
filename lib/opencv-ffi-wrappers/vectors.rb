
require 'nice-ffi'
require 'opencv-ffi-wrappers/misc/inject_with_index'

module CVFFI

  class FloatArrayCommon < NiceFFI::Struct
    include Enumerable
    include InjectWithIndex

    class << self; attr_accessor :nElem; end

    def nElem; self.class.nElem; end
    alias :length :nElem

    def each
      nElem.times { |i|
        yield d[i]
      }
    end

    #def [](i)
    #  d[i]
    #end

    #def []=(i)
    #  d[i] = i
    #end
  end

  class Float64 < FloatArrayCommon
    @nElem = 64
    layout :d, [ :float, @nElem ]
  end

  class Float128 < FloatArrayCommon
    @nElem = 128
    layout :d, [ :float, @nElem ]
  end
end
