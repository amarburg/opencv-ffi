
require 'nice-ffi'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

require 'opencv-ffi-ext/features2d/keypoint'

module CVFFI

  module Features2D
    module HarrisCommon

      class CvHarrisParams < NiceFFI::Struct
        layout :octaves, :int,
          :corn_thresh, :float,
          :dog_thresh, :float,
          :max_corners, :int,
          :num_layers, :int
      end

      class Params < CVFFI::Params
        param :octaves, 6
        param :corn_thresh, 0.01
        param :dog_thresh, 0.01
        param :max_corners, 5000
        param :num_layers, 4

        def to_CvHarrisParams
          CvHarrisParams.new( @params  )
        end
      end

    end

    module HarrisLaplace
      extend NiceFFI::Library

      libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
      pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
      load_library("cvffi", pathset)

      include HarrisCommon

      attach_function :cvHarrisLaplaceDetector, [:pointer, :pointer, CvHarrisParams.by_value ], CvSeq.typed_pointer

      def self.detect( image, params )
        params = params.to_CvHarrisParams unless params.is_a?( CvHarrisParams )

        kp_ptr = FFI::MemoryPointer.new :pointer
        storage = CVFFI::cvCreateMemStorage( 0 )

        image = image.ensure_greyscale

        seq_ptr = cvHarrisLaplaceDetector( image, storage, params )

        keypoints = CVFFI::CvSeq.new( seq_ptr )
        puts "Returned #{keypoints.total} keypoints"

        Keypoints.new( keypoints, storage )
      end
    end

    module HarrisAffine
      extend NiceFFI::Library

      libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
      pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
      load_library("cvffi", pathset)

      include HarrisCommon

      attach_function :cvHarrisAffineDetector, [:pointer, :pointer, CvHarrisParams.by_value ], CvSeq.typed_pointer

      def self.detect( image, params )
        params = params.to_CvHarrisParams unless params.is_a?( CvHarrisParams )

        kp_ptr = FFI::MemoryPointer.new :pointer
        storage = CVFFI::cvCreateMemStorage( 0 )

        image = image.ensure_greyscale

        seq_ptr = cvHarrisAffineDetector( image, storage, params )

        keypoints = CVFFI::CvSeq.new( seq_ptr )
        puts "Returned #{keypoints.total} keypoints"

        EllipticKeypoints.new( keypoints, storage )
      end


    end
  end
end
