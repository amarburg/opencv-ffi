
require 'opencv-ffi/core/types'

module CVFFI

  module CvPointMethods
    def got_what_i_need(a)
      a.class.method_defined?(:x) and a.class.method_defined?(:y) 
    end

    def /(a)
      if got_what_i_need a
        self.class.new( [ x.to_f/a.x.to_f, y.to_f/a.y.to_f ] )
      else
        self.class.new( [ x.to_f/a, y.to_f/a ] )
      end
    end

    def *(a)
      if got_what_i_need a
        self.class.new( [ x*a.x, y*a.y ] )
      else
        self.class.new( [ x*a, y*a ] )
      end
    end

    def -(a)
      if got_what_i_need a
        self.class.new( [ x.to_f-a.x, y.to_f-a.y ] )
      else
        self.class.new( [ x.to_f-a, y.to_f-a ] )
      end
    end
 
    def +(a)
      if  got_what_i_need a
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
    
    def ==(b)
      @x == b.x and @y == b.y
    end
    def ===(b)
      @x === b.x and @y === b.y
    end

    def to_Vector( homogeneous = true )
      Vector.elements( to_a( homogeneous ) )
    end
    alias :to_vector :to_Vector

    def to_a(homogeneous=true)
      if homogeneous
        [ @x/@w, @y/@w, 1.0 ]
      else
        [ @x, @y ]
      end
    end

    def neighbor?( p, radius )
      return false if (x-p.x).abs > radius or (y-p.y).abs > radius
      return false if l2distance(p) > radius
      true
    end

    def l2distance( b )
      Math::sqrt( (x-b.x)*(x-b.x) + (y-b.y)*(y-b.y) )
    end
    alias :distance_to :l2distance
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

    def to_Point
      Point.new( x, y )
    end

    def to_a(homogeneous=true)
      if homogeneous
        [ x, y, 1 ]
      else
        [x,y]
      end
    end
  end

  class CvPointBase
    include CvPointMethods
    include CvPointCastMethods
  end

  class CvPoint; def to_CvPoint; self; end; end
  class CvPoint2D32f; def to_CvPoint2D32f; self; end; end
  class CvPoint2D64f; def to_CvPoint2D64f; self; end; end

  class Point 
    include CvPointCastMethods
    include CvPointMethods

    attr_accessor :w, :y, :x

    def initialize( *args )
      if args.length == 2 and args[1] != nil
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

      @x = @x.to_f
      @y = @y.to_f
      @w = 1
    end

    def area
      @y*@x
    end
 end

#===========================================================
  module CvPoint3DMethods
    def got_what_i_need(a)
      a.method_defined?(:x) and a.method_defined?(:y) and a.method_defined(:z)
    end

    def /(a)
      if a.is_a? Point3D
        self.class.new( [ x.to_f/a.x.to_f, y.to_f/a.y.to_f, z.to_f/a.z.to_f ] )
      else
        self.class.new( [ x.to_f/a, y.to_f/a, z.to_f/z ] )
      end
    end

    def *(a)
      if a.is_a? Point3D
        self.class.new( [ x*a.x, y*a.y, z*a.z ] )
      else
        self.class.new( [ x*a, y*a, z*a.z ] )
      end
    end

    def -(a)
      if a.is_a? Point3D
        self.class.new( [ x.to_f-a.x, y.to_f-a.y, z.to_f-a.z ] )
      else
        self.class.new( [ x.to_f-a, y.to_f-a, z.to_f-a ] )
      end
    end
 
    def +(a)
      if a.is_a? Point3D
        self.class.new( [ x+a.x, y+a.y, z+a.z ] )
      else
        self.class.new( [ x+a, y+a, z+a ] )
      end
    end

    def ==(b)
      @x == b.x and @y == b.y and @z == b.z
    end
    def ===(b)
      @x === b.x and @y === b.y and @z === b.z
    end

    def to_Vector( homogeneous = true )
      Vector.elements( to_a(homogeneous) )
    end
    alias :to_vector :to_Vector

    def to_a(homogeneous=true)
      if homogeneous
        [@x/@w, @y/@w, @z/@w, 1]
      else
        [@x, @y, @z]
      end
    end

end
  
  module CvPoint3DCastMethods
    def to_CvPoint3D64f
      CvPoint3D64f.new( :x => x, :y => y, :z => z )
    end

    def to_CvPoint3D32f
      CvPoint3D32f.new( :x => x, :y => y, :z => z )
    end

    def to_a( homogeneous = true )
      if homogeneous
        [x,y,z,1]
      else
        [x,y,z]
      end
    end
  end

  class CvPoint3DBase
    include CvPoint3DMethods
    include CvPoint3DCastMethods
  end

  class CvPoint3D32f; def to_CvPoint3D32f; self; end; end
  class CvPoint3D64f; def to_CvPoint3D64f; self; end; end

  class Point3D
    include CvPoint3DCastMethods
    include CvPoint3DMethods

    attr_accessor :w, :z, :y, :x

    def initialize( *args )
      if args.length == 3
        @x = args[0]
        @y = args[1]
        @z = args[2]
      else
        args = args.shift

        case args
        when Hash
          @z = args[:z]
          @y = args[:y]
          @x = args[:x]
        when Array
          @x = args[0]
          @y = args[1]
          @z = args[2]
      else
        @x = args.x
        @y = args.y
        @z = args.z
      end
      end

      @w = 1
    end

  end




end
