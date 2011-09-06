
require 'opencv-ffi/core/types'
require 'opencv-ffi-wrappers/core/common'

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
    include PointSizeCommon

    attr_accessor :y, :x

    def initialize( args )

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

    def area
      @y*@x
    end
           
  end




end
