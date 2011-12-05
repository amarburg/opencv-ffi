
require 'nice-ffi'

require 'opencv-ffi-wrappers/misc/params'

module CVFFI

  module SIFT
    extend NiceFFI::Library

    libs_dir = File.dirname(__FILE__) + "/../../ext/aishack-sift/"
    pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
    load_library("cvffi_sift", pathset)

    class SiftParams < NiceFFI::Struct
      layout :octaves, :int,
        :intervals, :int
    end

    NUM_BINS = 36
    class SiftKeypoint < NiceFFI::Struct
      layout :x, :float,
        :y, :float,
        :mag, [:float, NUM_BINS],
        :orien, [:float, NUM_BINS],
        :num_bins, :uint,
        :scale, :uint
    end

    FV_LENGTH = 128
    class SiftDescriptor < NiceFFI::Struct
      layout :x, :float,
        :y, :float,
        :fv, [:float, FV_LENGTH],
        :fv_length, :uint
    end

    class SiftResults< NiceFFI::Struct
      layout :kps, :pointer,
        :descs, :pointer,
        :len, :uint
    end

    class Results
      attr_accessor :kps, :descs

      def initialize( k, d )
        @kps = k
        @descs = d
      end

      def size
        @kps.length
      end
      alias :length :size

      def to_a
        a = Array.new
        a << Array.new( size ) { |i|
          kp = kps[i]
          [ kp.x, kp.y, kp.mag, kp.orien, kp.num_bins, kp.scale ]
        }
        a << Array.new( size ) { |i|
          d = descs[i]
          [d.x, d.y, Array.new(d.fv_length) {|i| d.fv[i]}, d.fv_length]
        }
      end

      def self.from_a( a )
        a = YAML::load(a) if a.is_a? String
        raise "Don't know what to do" unless a.is_a? Array
        raise "Result isn't a two-element array" unless a.length == 2

        kps = a[0]
        descs = a[1]
      end

    end

    attach_function :siftDetectDescribe_real, :siftDetectDescribe, [ :pointer, SiftParams.by_value ], SiftResults.typed_pointer


    class Params < CVFFI::Params
      param :octaves, 4
      param :intervals, 5 

      def to_SiftParams
        SiftParams.new( octaves: octaves, 
                       intervals: intervals )
      end

    end


    def self.detect( image, params )
      params = params.to_SiftParams unless params.is_a?( SiftParams )

      puts "Running SIFT algorithm with #{params.octaves} octaves and #{params.intervals} intervals."

      kps = siftDetectDescribe_real( image, params )

      # Unwrap the SiftKeypoints to an Array.
      keypoints = Array.new( kps.len ) { |i|
        SiftKeypoint.new( kps.kps + (i*SiftKeypoint.size))
      }
      descs = Array.new( kps.len ) { |i|
        SiftDescriptor.new( kps.descs + (i*SiftDescriptor.size) )
      }

      p keypoints[0]
      p descs[0]

      Results.new( keypoints, descs )
    end


  end
end
