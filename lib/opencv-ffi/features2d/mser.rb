
require 'opencv-ffi/cvffi'
require 'opencv-ffi/core'
require 'opencv-ffi/features2d/library'

module CVFFI

  class CvMSERParams < NiceFFI::Struct
      # delta, in the code, it compares (size_{i}-size_{i-delta})/size_{i-delta}
      #  suggested default: 5
    layout :delta, :int,
      # prune the area which bigger than maxArea
      #   suggested default: 60
      :maxArea, :int,
      # prune the area which smaller than minArea
      #   suggested default: 14400
      :minArea, :int,
      # prune the area have simliar size to its children
      #   suggested default: 0.25
      :maxVariation, :float,
      # trace back to cut off mser with diversity < min_diversity
      #   suggested default: 0.2
      :minDiversity, :float,

      # for color image, the evolution steps
      #   suggested default: 200
      :maxEvolution, :int,
      # the area threshold to cause re-initialize
      #   suggested default: 1.01
      :areaThreshold, :double,
      # ignore too small margin
      #   suggested default: 0.003
      :minMargin, :double,
      # the aperture size for edge blur
      #   suggested default: 5
      :edgeBlurSize, :int
  end

  # CVAPI(void) cvExtractMSER( CvArr* _img, CvArr* _mask, CvSeq** contours, CvMemStorage* storage, CvMSERParams params );
  attach_function :cvExtractMSER, [:pointer, :pointer, :pointer, :pointer, CvMSERParams.by_value], :void

end
