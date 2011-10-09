
require 'opencv-ffi-ext/fast'
require 'opencv-ffi'

module CVFFI
  module FAST

    class FASTResultsArray
      include Enumerable

      attr_accessor :points
      attr_accessor :nPoints

      def initialize( pts, nPts )
        @points = pts
        @nPoints = nPts

        # Define a destructor do dispose of the results
        destructor = Proc.new { pts.free }
        ObjectSpace.define_finalizer( self, destructor )
      end

      def each
        if @nPoints > 0
          0.upto(@nPoints-1) { |i|
yield Xy.new( @points[i] )
          }
        end
      end

      alias :size :nPoints

    end

    VALID_SIZES = [ 9, 10, 11, 12 ]

    def self.size_valid?( sz )
      VALID_SIZES.include? sz
    end

    def Params
      attr_accessor :size, :threshold

      def initialize( opts = {} )
        @size = opts[:size] || 9
        @threshold = opts[:threshold] || 20

        raise "Hm, invalid size #{opts[:size]} specified for FAST keypoint detector" unless size_valid? opts[:size] 
      end

      def to_hash
        { :size => @size, :threshold => @threshold }
      end
    end


    def self.detect( img, params )
      FASTDetect( params.size, img, params.threshold )
    end

    def self.FASTDetect( size, img, threshold )
      nResults = FFI::MemoryPointer.new :int

      if img.is_a?( IplImage )
        # Ensure the image is b&w
        img = img.ensure_greyscale

        results = FFI::Pointer.new :pointer, method("fast#{size}_detect").call( img.imageData, img.width, img.height, img.widthStep, threshold, nResults )
      else
        raise ArgumentError, "Don't know how to deal with image class #{img.class}"
      end

      # Dereference the two pointers
      nPoints = nResults.read_int
      points = FFI::Pointer.new Xy, results

      FASTResultsArray.new( points, nPoints )
    end

    def self.FAST9Detect( img, threshold );  FASTDetect( 9, img, threshold ); end
    def self.FAST10Detect( img, threshold ); FASTDetect( 10, img, threshold ); end
    def self.FAST11Detect( img, threshold ); FASTDetect( 11, img, threshold ); end
    def self.FAST12Detect( img, threshold ); FASTDetect( 12, img, threshold ); end

  end
end
