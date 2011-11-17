
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

    class SiftKeypoints < NiceFFI::Struct
      layout :kps, :pointer,
             :len, :uint
    end

    attach_function :siftDetect_real, :siftDetect, [ :pointer, SiftParams.by_value ], SiftKeypoints.typed_pointer


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

      kps = siftDetect_real( image, params )

      p kps


      kps
    end


  end
end
