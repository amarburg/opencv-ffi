require 'opencv-ffi/core/library'

module CVFFI

  class CvRect < NiceFFI::Struct
    layout :x, :int,
           :y, :int,
           :width, :int,
           :height, :int
  end

  class CvSizeBase < NiceFFI::Struct
  end

  class CvSize < CvSizeBase
    layout :width, :int,
           :height, :int
  end

  class CvSize2D32f < CvSizeBase
    layout :width, :float,
           :height, :float
  end

  class CvSize2D64f < CvSizeBase
    layout :width, :double,
           :height, :double
  end

  class CvPointBase < NiceFFI::Struct
  end

  class CvPoint < CvPointBase
    layout :x, :int,
           :y, :int
  end

  class CvPoint2D32f < CvPointBase
    layout :x, :float,
           :y, :float
  end

  class CvPoint2D64f < CvPointBase
    layout :x, :double,
           :y, :double
  end

  class CvPoint3DBase < NiceFFI::Struct
  end

  class CvPoint3D32f < CvPoint3DBase
    layout :x, :float,
           :y, :float,
           :z, :float
  end

  class CvPoint3D64f < CvPoint3DBase
    layout :x, :double,
           :y, :double,
           :z, :double
  end


  
  #
  # CvScalar
  #
  class CvScalar < NiceFFI::Struct
#    layout :val, [:double, 4 ]
    layout :w, :double,
           :x, :double,
           :y, :double,
           :z, :double
  end

  #
  # CvMat
  #
  class CvMat < NiceFFI::Struct
    layout :type, :int,
           :step, :int,
           :refcount, :pointer,
           :hdr_refcount, :int,
           :data, :pointer,
           :height, :int,
           :width, :int

    hidden :refcount, :hdr_refcount

    # These are handled by a union in the original structure
    def rows; height; end
    def cols; width; end

    def self.release ptr
      CVFFI::releaseMat ptr
    end
  end

  #
  # IplImage
  #
  enum :IplDepth, [ :IPL_DEPTH_1U, 1,
                    :IPL_DEPTH_8U, 8,
                    :IPL_DEPTH_16U, 16,
                    :IPL_DEPTH_32F, 32 ]

  class IplImage < NiceFFI::Struct
    layout :nSize, :int,
           :ID, :int,
           :nChannels, :int,
           :alphaChannel, :int,
           :depth, :int,
           :colorModel, [:char, 4],
           :channelSeq, [:char, 4],
           :dataOrder, :int,
           :origin, :int,
           :align,  :int,
           :width,  :int,
           :height, :int,
           :roi, :pointer,
           :maskROI, :pointer,
           :imageId, :pointer,
           :tileInfo, :pointer,
           :imageSize, :int,
           :imageData, :pointer,
           :widthStep, :int,
           :BorderMode, [:int, 4],
           :imageDataOrigin, :pointer

#    def self.release(ptr)
#      p ptr
#      CVFFI::cvReleaseData( ptr )
#    end
  end


  #
  # CvSeq and assoc
  #
  class CvSeqBlock < NiceFFI::Struct
    layout :prev, NiceFFI::TypedPointer( CvSeqBlock ),
           :next, NiceFFI::TypedPointer( CvSeqBlock ),
           :start_index, :int,
           :count, :int,
           :data, :pointer
  end

  class CvMemBlock < NiceFFI::Struct
    layout :prev, NiceFFI::TypedPointer( CvMemBlock ),
           :next, NiceFFI::TypedPointer( CvMemBlock )
  end

  class CvMemStorage < NiceFFI::Struct
    layout :signature, :int,
           :bottom, NiceFFI::TypedPointer( CvMemBlock ),
           :top, NiceFFI::TypedPointer( CvMemBlock ),
           :parent, NiceFFI::TypedPointer( CvMemStorage ),
           :block_size, :int,
           :free_space, :int

    def self.release ptr
      CVFFI::releaseMemStorage ptr
    end
  end

  class CvSeq < NiceFFI::Struct
    layout :flags, :int,
           :header_size, :int,
           :h_prev, NiceFFI::TypedPointer( CvSeq ),
           :h_next, NiceFFI::TypedPointer( CvSeq ),
           :v_prev, NiceFFI::TypedPointer( CvSeq ),
           :v_prev, NiceFFI::TypedPointer( CvSeq ),
           :total, :int,
           :elem_size, :int,
           :block_max, :pointer,
           :ptr, :pointer,
           :delta_elems, :int,
           :storage, NiceFFI::TypedPointer( CvMemStorage ),
           :free_blocks, NiceFFI::TypedPointer( CvSeqBlock ),
           :first, NiceFFI::TypedPointer( CvSeqBlock )
  end

end

