
require 'nice-ffi'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

require 'opencv-ffi-ext/features2d/keypoint'

module CVFFI

  module Features2D

    # This module calls the cvffi extension library's SIFT functions.
    # These functions, in turn, are re-written versions of OpenCV's SIFT 
    # functions which expose a C API rather than un- and re-wrapping C++
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

      ## Unfortunately, uses a bespoke "features" structure internally
      class CvSIFTFeature < NiceFFI::Struct
        layout :x, :double,
               :y, :double,
               :scale, :double,
               :orientation, :double,
               :descriptor_length, :int,
               :descriptor, [ :double, 128 ],
               :feature_data, :pointer,
               :class_id, :int,
               :response, :float

        def to_a
          [ x, y, scale, orientation, response ]
        end

        def self.from_a(a)
          CvSIFTFeature.new( x: a[0], y: a[1], scale: a[2], orientation: a[3], response: a[4] )
        end

        def self.create_cvseq( pool )
          CVFFI::cvCreateSeq( 0, CvSeq.size, CvSIFTFeature.size, pool )
        end
      end

      class Results < SequenceArray

        def initialize( seq, pool )
          super( seq, pool, CvSIFTFeature )
        end

      end

#      def self.from_a( a )
#        a = YAML::load(a) if a.is_a? String
#        raise "Don't know what to do" unless a.is_a? Array
#
#        pool = CVFFI::cvCreateMemStorage(0)
#        cvseq = CVFFI::OpenSURF::createOpenSURFPointSequence( pool )
#        seq = Sequence.new cvseq
#        
#        a.each { |r|
#          raise "Hm, not what I expected" unless r.length == 6
#          point = CVFFI::OpenSURF::OpenSURFPoint.new( '' )
#          # Hm, the embedded CvPoint buggers up initialization by hash
#          point.scale = r[2]
#          point.orientation = r[3]
#          point.laplacian = r[4]
#          d = r[5].unpack('m')[0].unpack('e64')
#
#          d.each_with_index { |d,i| point.descriptor[i] = d }
#
#          # r[5].unpack('e64')
#          point.pt.x = r[0]
#          point.pt.y = r[1]
#          seq.push( point )
#        }
#
#
#        ra = ResultArray.new( cvseq, pool )
#      end



      ## Original C wrappers around OpenCV C++ code
      attach_function :cvSIFTWrapperDetect, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void
      attach_function :cvSIFTWrapperDetectDescribe, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], CvMat.typed_pointer

      ## "remixed" OpenCV code which now works directly in C structures
      attach_function :cvSIFTDetect, [:pointer, :pointer, :pointer, 
                              CvSIFTParams.by_value ], CvSeq.typed_pointer

      #attach_function :cvSIFTDetectDescribe, [:pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], CvMat.typed_pointer

      def self.detect( image, params )
        params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )

        storage = CVFFI::cvCreateMemStorage( 0 )

        keypoints = CVFFI::CvSeq.new cvSIFTDetect( image.ensure_greyscale, nil, storage, params )

        Results.new( keypoints, storage )
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
