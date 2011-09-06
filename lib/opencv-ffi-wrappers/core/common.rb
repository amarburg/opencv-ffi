

module CVFFI

  module PointSizeCommon

    def /(a)
      if a.class == self.class 
        self.class.new( [ x/a.x, y/a.y ] )
      else
        self.class.new( [ x/a, y/a ] )
      end
    end

    def *(a)
      if a.class == self.class
        self.class.new( [ x*a.x, y*a.y ] )
      else
        self.class.new( [ x*a, y*a ] )
      end
    end

    def -(a)
      if a.class == self.class
        self.class.new( [ x-a.x, y-a.y ] )
      else
        self.class.new( [ x-a, y-a ] )
      end
    end
 
    def +(a)
      if a.class == self.class
        self.class.new( [ x+a.x, y+a.y ] )
      else
        self.class.new( [ x+a, y+a ] )
      end
    end

  end
end

