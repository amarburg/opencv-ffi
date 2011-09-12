
require 'opencv-ffi/core/types'

module CVFFI

  module CvPointFunctions
  end

  module CvPointCastMethods
    def to_CvPoint2D64f
      CvPoint2D64f.new( :x => x, :y => y )
    end

    def to_CvPoint2D32f
      CvPoint2D32f.new( :x => x, :y => y )
    end

    def to_CvPoint
      CvPoint.new( :x => x.to_i, :y => y.to_i )
    end
  end

  class CvPointBase
    include CvPointFunctions
    include CvPointCastMethods
  end

  class CvPoint; def to_CvPoint; self; end; end
  class CvPoint2D32f; def to_CvPoint2D32f; self; end; end
  class CvPoint2D64f; def to_CvPoint2D64f; self; end; end

  class Point 
    include CvPointCastMethods

    attr_accessor :y, :x

    def initialize( *args )
      if args.length == 2
        @x = args[0]
        @y = args[1]
      else
        args = args.shift

        case args
        when Hash
          @y = args[:y]
          @x = args[:x]
        when Array
          @x = args[0]
          @y = args[1]
      else
        @x = args.x
        @y = args.y
      end
      end

    end

    def area
      @y*@x
    end
       
    def /(a)
      if a.is_a? Point
        self.class.new( [ x.to_f/a.x.to_f, y.to_f/a.y.to_f ] )
      else
        self.class.new( [ x.to_f/a, y.to_f/a ] )
      end
    end

    def *(a)
      if a.is_a? Point
        self.class.new( [ x*a.x, y*a.y ] )
      else
        self.class.new( [ x*a, y*a ] )
      end
    end

    def -(a)
      if a.is_a? Point
        self.class.new( [ x.to_f-a.x, y.to_f-a.y ] )
      else
        self.class.new( [ x.to_f-a, y.to_f-a ] )
      end
    end
 
    def +(a)
      if a.is_a? Point
        self.class.new( [ x+a.x, y+a.y ] )
      else
        self.class.new( [ x+a, y+a ] )
      end
    end

    def rotate( rads )
      sa = Math::sin rads
      ca = Math::cos rads
      self.class.new( x*ca - y*sa,
                      x*sa + y*ca )
    end

    
  end




end
