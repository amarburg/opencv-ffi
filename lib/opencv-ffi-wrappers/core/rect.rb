
require 'opencv-ffi-wrappers/core'

module CVFFI

  class Rect
    attr_accessor :size, :origin

    def initialize( args )
      case args
      when Array
        @origin = Point.new( args[0..1] )
        @size   = Size.new(  args[2..3] )
      when Hash
        if args[:size]
          @size = Size.new args[:size]
        else
          @size = Size.new(args)
        end

        if args[:origin] 
          @origin = Point.new( args[:origin] )
        elsif args[:center]
          @origin = Point.new( args[:center] - @size/2.0 )
        else
          @origin = Point.new(args)
        end

      else
        @size = Size.new args.size
        @origin = Point.new args.origin
      end
    end

    def to_CvRect
      CvRect.new( :x => @origin.x, :y => @origin.y,
              :width => @size.width, :height => @size.height )
    end

    def each( &blk )
      size.width.to_i.times { |x|
        size.height.to_i.times { |y|
          pt = Point.new(origin.x+x, origin.y+y ) 
          blk.call( pt )
        }
      }
    end

    def width; size.width; end
    def height; size.height; end

    def each_with_relative( &blk )
      size.width.to_i.times { |x|
        size.height.to_i.times { |y|
          pt = Point.new(x,y)
          blk.call( pt+origin, pt )
        }
      }
    end


  end
end
