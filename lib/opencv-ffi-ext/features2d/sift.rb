
require 'nice-ffi'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

require 'opencv-ffi-ext/features2d/keypoint'

module CVFFI

  module Features2D

    # This module calls the cvffi extension library's SIFT functions.
    # These functions, in turn, are just thin C wrappers around OpenCV's
    # SIFT functions ... which are written in C++
    module SIFT
      extend NiceFFI::Library

      libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
      pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
      load_library("cvffi", pathset)

      class CvSIFTParams < NiceFFI::Struct
        layout :octaves, :int,
          :intervals, :int,
          :threshold, :double,
          :edgeThreshold, :double,
          :magnification, :double
      end

      class Params < CVFFI::Params
        param :octaves, 4
        param :intervals, 5 
        param :threshold, 0.04
        param :edgeThreshold, 10.0 
        param :magnification, 3.0

        def to_CvSIFTParams
          CvSIFTParams.new( @params  )
        end

      end

      attach_function :cvSIFTDetect, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void
      attach_function :cvSIFTDetectDescribe, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], CvMat.typed_pointer

      def self.detect( image, params )
        params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )

        kp_ptr = FFI::MemoryPointer.new :pointer
        storage = CVFFI::cvCreateMemStorage( 0 )
        image = image.ensure_greyscale

        cvSIFTDetect( image, nil, kp_ptr, storage, params )

        seq_ptr = kp_ptr.read_pointer()
        keypoints = CVFFI::CvSeq.new( seq_ptr )

        Keypoints.new( keypoints, storage )
      end

      def self.detect_describe( image, params )
        params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )

        # I believe this is re-shaped by the function
        descriptors = CVFFI::CvMat.new( CVFFI::cvCreateMat( 1,1, :CV_32F ) )
        kp_ptr = FFI::MemoryPointer.new :pointer
        storage = CVFFI::cvCreateMemStorage( 0 )
        image = image.ensure_greyscale

        descriptors = CvMat.new( cvSIFTDetectDescribe( image, nil, kp_ptr, storage, params ))

        keypoints = CVFFI::CvSeq.new( kp_ptr.read_pointer() )

        descs = descriptors.to_Matrix.row_vectors

        Keypoints.new( keypoints, storage, descs )
      end

    end
  end
end
