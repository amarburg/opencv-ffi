
require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core/common'

module CVFFI

  module CvSizeFunctions
    def x; self.width; end
    def y; self.height; end

    def x=(a); self.width=a; end
    def y=(a); self.height=a; end
  end

  module CvSizeCastMethods
    def to_CvSize2D64f
      CvSize2D64f.new( :width => x, :height => y )
    end

    def to_CvSize2D32f
      CvSize2D32f.new( :width => x, :height => y )
    end

    def to_CvSize
      CvSize.new( :width => x.to_i, :height => y.to_i )
    end
  end

  class CvSizeBase
    include CvSizeFunctions
    include CvSizeCastMethods
  end

  class CvSize; def to_CvSize; self; end; end
  class CvSize2D32f; def to_CvSize2D32f; self; end; end
  class CvSize2D64f; def to_CvSize2D64f; self; end; end

  class Size 
    include CvSizeCastMethods
    include PointSizeCommon

    attr_accessor :height, :width
    alias :x :width
    alias :y :height

    def initialize( *args )
      if args.length == 2
        @width = args[0]
        @height = args[1]
      else
        args = args.shift
        case args
        when Hash
          @height = args[:height] || args[:y]
          @width = args[:width] || args[:x]
        when Array
          @width = args[0]
          @height = args[1]
        else
          @width = args.width || args.x
          @height = args.height || args.y
        end
      end
    end

    def area
      @height*@width
    end

    def /(a)
      Size.new( [ x/a, y/a ] )
    end
  end




end
