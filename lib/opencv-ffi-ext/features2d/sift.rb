

require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/misc/params'

require 'opencv-ffi-ext/features2d/keypoint'

module CVFFI
  extend NiceFFI::Library

  libs_dir = File.dirname(__FILE__) + "/../../../ext/opencv-ffi/"
  pathset = NiceFFI::PathSet::DEFAULT.prepend( libs_dir )
  load_library("cvffi", pathset)

  class CvSIFTParams < NiceFFI::Struct
    layout :nOctaves, :int,
           :nOctaveLayers, :int,
           :threshold, :double,
           :edgeThreshold, :double,
           :magnification, :double

    def to_CvSIFTParams
      self
    end
  end

  ## void cvSIFTDetect( const CvArr *img, const CvArr *mask, 
  #                     CvSeq **keypoints, CvMemStorage *storage, 
  #                     CvSIFTParams_t params )
  attach_function :cvSIFTDetect, [ :pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void 
  # void cvSIFTDetectDescribe( const CvArr *img, const CvArr *mask, CvSeq **keypoints,
  #                            CvMat *descriptors, CvMemStorage *storage, CvSIFTParams_t params )
  attach_function :cvSIFTDetectDescribe, [ :pointer, :pointer, :pointer, :pointer, :pointer, CvSIFTParams.by_value ], :void 

##
# An here's the "wrapper."  Since the C API to SIFT is homemade, there really 
# isn't a concept of a "pure" SIFT API to contrast with the wrapper.  So here are both

  module SIFT

    class ResultsArray

      attr_accessor :kps

      def initialize( kps, descs = nil )
        @kps = kps
        @descs = descs
        @results = Array.new( @kps.length )
      end

      def size
        @kps.length
      end
      alias :length :size

      def [](i); result(i); end
      def result(i)
        @results[i] ||= CVFFI::CvKeyPoint.new( @kps[i] )
      end

      def each
        @results.each { |s| yield s }
      end
    end

    class Params < CVFFI::Params
      param :nOctaves, 4
      param :nOctaveLayers, 3
      param :threshold, 0.04
      param :edgeThreshold, 10.0
      param :magnification, 3.0

      def to_CvSIFTParams
        CVFFI::CvSIFTParams.new( @params )
      end
    end

    def self.detect( img, params )

      img = img.to_IplImage
      params = params.to_CvSIFTParams
      raise ArgumentError unless params.is_a?( CvSIFTParams ) 

      kp_ptr = FFI::MemoryPointer.new :pointer
      mem_storage = CVFFI::cvCreateMemStorage( 0 )

      CVFFI::cvSIFTDetect( img, nil, kp_ptr, mem_storage, params )

      ResultsArray.new( Sequence.new( CvSeq.new( kp_ptr.read_pointer )) )
    end
 
  end

end
