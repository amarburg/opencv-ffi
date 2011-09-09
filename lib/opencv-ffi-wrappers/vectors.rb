
require 'nice-ffi'

module CVFFI

  class FloatArrayCommon < NiceFFI::Struct
    include Enumerable

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
