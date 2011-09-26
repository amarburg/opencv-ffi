
require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core'


module CVFFI

  module CvScalarFunctions
    def self.included(base)
      base.extend(ClassMethods)
    end

    def to_CvScalar
      self
    end

    module ClassMethods 
   end


  end

  class CvMat
    include CvMatFunctions
  end



  class Scalar

    def initialize( *args )
      @order = :BGR
      w=x=y=z=0

      if args[0].is_a?( Hash )
        args = args[0]

        @order = args[:channel_order] if args[:channel_order]
      a,b,c,d = color_symbols

      w = args[:w] || args[a] || 0
      x = args[:x] || args[b] || 0
      y = args[:y] || args[c] || 0
      z = args[:z] || args[d] || 0
      else
         w,x,y,z = args
      end

      @s = CVFFI::CvScalar.new( :w => w, :x => x, :y => y, :z => z )
    end

    def color_symbols
      case @order
      when :BGR then
        [ :b, :g, :r, :a ]
      else
        raise "Hm, the Scalar::order is undefined"
      end
    end

    def to_CvScalar
      @s
    end

    def []=(i,x)
      a,b,c,d = color_symbols

      case i.downcase
      when :w,a then
        @s.w = x
      when :x,b then
        @s.x = x
      when :y,c then
        @s.y = x
      when :z,d then
        @s.z = x
      else 
        raise "Hm, don't understand index to CVFFI::Scalar[]="
      end
    end


    def [](i)
      a,b,c,d = color_symbols

      case i.downcase
      when :w,a then
        @s.w
      when :x,b then
        @s.x
      when :y,c then
        @s.y
      when :z,d then
        @s.z
      else
        nil
      end
    end

    def to_s
      "CvScalar(#{ [@s.w, @s.w, @s.y, @s.z].join(',') })"
    end
  end
end
