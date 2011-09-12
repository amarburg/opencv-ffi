
require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core/point'

module CVFFI

  module CvSizeFunctions
    def x; self.width; end
    def y; self.height; end

    def x=(a); self.width=a; end
    def y=(a); self.height=a; end

    def ===(b)
      width === b.width and height === b.height
    end
    def ==(b)
      width == b.width and height == b.height
    end
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

  class Size < Point
    include CvSizeCastMethods

    #attr_accessor :height, :width
    alias :width :x
    alias :height :y
    alias :width= :x=
    alias :height= :y=

    def initialize( *args )
      if args.length == 2
        @x= args[0]
        @y= args[1]
      else
        args = args.shift
        case args
        when Hash
          @x= args[:width] || args[:x]
          @y= args[:height] || args[:y]
        when Array
          @x = args[0]
          @y = args[1]
        else
          @x = args.width || args.x
          @y = args.height || args.y
        end
      end
    end

    def area
      height*width
    end

    def floor
      @x = x.to_i
      @y = y.to_i
    end

  end




end
