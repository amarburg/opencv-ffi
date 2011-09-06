

module CVFFI

  module PointSizeCommon

    def /(a)
      if a.is_a? Point
        self.class.new( [ x/a.x, y/a.y ] )
      else
        self.class.new( [ x/a, y/a ] )
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
        self.class.new( [ x-a.x, y-a.y ] )
      else
        self.class.new( [ x-a, y-a ] )
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

