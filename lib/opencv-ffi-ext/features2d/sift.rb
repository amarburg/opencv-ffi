
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
          :magnification, :double,
          :recalculateAngles, :int 
      end

      class Params < CVFFI::Params
        param :octaves, 4
        param :intervals, 5 
        param :threshold, 0.04
        param :edgeThreshold, 10.0 
        param :magnification, 3.0
        param :recalculateAngles, 1.0

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

        def self.keys
          [ :x, :y, :scale, :orientation, :response, :descriptor_length ]
        end

        def to_a
          CvSIFTFeature::keys.map { |key|
            self[key]
          }.push descriptor.to_a.pack( "g#{descriptor_length}" )
        end

        def self.from_a(a)
          raise "Not enough elements in array to unserialize (#{a.length} < #{keys.length}" unless a.length >= keys.length

          feature = CvSIFTFeature.new
          keys.each { |key|
            feature[key] = a.shift
          }
          desc =  a.shift.unpack("g#{feature.descriptor_length}")
          feature.descriptor_length.times { |j| feature[:descriptor][j] = desc[j] }

          feature
        end

        def ==(b)
          result = CvSIFTFeature::keys.reduce( true ) { |m,s|
            #puts "Key #{s} doesn't match" unless self[s] == b[s]
            m = m and (self[s] == b[s])
          }

          if descriptor_length > 0 
            result =( result and (descriptor.to_a == b.descriptor.to_a) )
          end

          result
        end
      end

      class Results < SequenceArray

        def initialize( seq, pool )
          super( seq, pool, CvSIFTFeature )
        end

        def self.from_a( a )
          SequenceArray.from_a( a, CvSIFTFeature )
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

      attach_function :cvSIFTDetectDescribe, [:pointer, :pointer, :pointer, 
                              CvSIFTParams.by_value, :pointer ], CvSeq.typed_pointer

      def self.detect( image, params )
        params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )
        storage = CVFFI::cvCreateMemStorage( 0 )
        keypoints = CVFFI::CvSeq.new cvSIFTDetect( image.ensure_greyscale, nil, storage, params )
        Results.new( keypoints, storage )
      end

      def self.detect_describe( image, params, keypoints = nil )
        params = params.to_CvSIFTParams unless params.is_a?( CvSIFTParams )
        storage = CVFFI::cvCreateMemStorage( 0 )
        keypoints = keypoints.to_CvSeq if keypoints
        keypoints = CVFFI::CvSeq.new cvSIFTDetectDescribe( image.ensure_greyscale, nil, storage, params, keypoints )
        Results.new( keypoints, storage )
      end

    end
  end
end
