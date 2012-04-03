
require 'opencv-ffi/core/library'
require 'opencv-ffi/core/types'

module CVFFI

  CvMatType = enum :cvMatType, [ :CV_8U, 0,
                     :CV_8UC1, 0,
                     :CV_8S, 
                     :CV_16U,
                     :CV_16S,
                     :CV_32S,
                     :CV_32F,
                     :CV_64F,
                     :CV_USRTYPE1,
                     :CV_8UC2, 8,
                     :CV_8SC2, 
                     :CV_16UC2,
                     :CV_16SC2,
                     :CV_32SC2,
                     :CV_32FC2,
                     :CV_64FC2,
                     :CV_8UC3, 16,
                     :CV_8SC3, 
                     :CV_16UC3,
                     :CV_16SC3,
                     :CV_32SC3,
                     :CV_32FC3,
                     :CV_64FC3 ]

  ## As present, the type encodes 9 bits of nChannels and 3 bits of typ
  def self.matMagicType( m )
    type = case m.type
           when Fixnum
             m.type
           when Symbol
             CvMatType[m.type]
           else
             raise "Can't convert #{m.type} to a numberic OpenCV type"
           end

    type & 0xFFF
  end

  def self.matChannels( m )
    (matMagicType(m) >> 3) + 1
  end

  # A bit clumsy
  def self.matType( m )
    case m.type & 0x7
    when :CV_8U; :CV_8U
    else
      assert RuntimeError, "This shouldn't happen!"
    end
  end

  attach_function :cvAddWeighted, [ :pointer, :double, :pointer, :double, :double, :pointer ], :void

  attach_function :cvCloneImage, [ :pointer ], IplImage.typed_pointer
  attach_function :cvCloneMat,   [ :pointer ], CvMat.typed_pointer

  enum :cvCmpTypes, [ :CV_CMP_EQ, :CV_CMP_GT, :CV_CMP_GE, :CV_CMP_LT, :CV_CMP_LE, :CV_CMP_NE ]
  attach_function :cvCmp, [:pointer, :pointer, :pointer, :int], :void

  attach_function :cvCreateMat, [ :int, :int, :cvMatType ], CvMat.typed_pointer
  attach_function :cvCreateImage, [ CvSize.by_value, :int, :int ], IplImage.typed_pointer

  attach_function :cvCopy, [ :pointer, :pointer, :pointer ], :void


  attach_function :cvSetImageROI, [:pointer, CvRect.by_value ], :void
  attach_function :cvGetImageROI, [:pointer], CvRect.by_value
  attach_function :cvResetImageROI, [:pointer], :void

  # CVAPI(CvScalar) cvGet2D( const CvArr* arr, int idx0, int idx1 );
  attach_function :cvGet1D, [ :pointer, :int ], CvScalar.by_value
  attach_function :cvGet2D, [ :pointer, :int, :int ], CvScalar.by_value
  attach_function :cvGet3D, [ :pointer, :int, :int, :int ], CvScalar.by_value

  attach_function :cvGetReal1D, [ :pointer, :int ], :double
  attach_function :cvGetReal2D, [ :pointer, :int, :int ], :double
  attach_function :cvGetReal3D, [ :pointer, :int, :int, :int ], :double

  enum :cvNormTypes, [ :CV_C, 1,
                       :CV_L1, 2,
                       :CV_L2, 4 ]
  attach_function :real_cvNorm, :cvNorm, [ :pointer, :pointer, :int, :pointer ], :double
  def self.cvNorm( arr1, arr2 = nil, normType = :CV_L2, mask = nil )
    real_cvNorm( arr1, arr2, normType, mask )
  end

  attach_function :cvSet,  [ :pointer, CvScalar.by_value, :pointer ], :void

  attach_function :cvSet1D, [ :pointer, :int, CvScalar.by_value ], :void
  attach_function :cvSet2D, [ :pointer, :int, :int, CvScalar.by_value ], :void
  attach_function :cvSet3D, [ :pointer, :int, :int, :int, CvScalar.by_value ], :void

  attach_function :cvSetReal1D, [ :pointer, :int, :double ], :void
  attach_function :cvSetReal2D, [ :pointer, :int, :int, :double ], :void
  attach_function :cvSetReal3D, [ :pointer, :int, :int, :int, :double ], :void

  attach_function :cvSetIdentity, [ :pointer, CvScalar.by_value ], :void
  attach_function :cvSetZero, [ :pointer ], :void

  attach_function :cvSolveCubic, [:pointer, :pointer ], :void
  attach_function :cvSplit, [:pointer, :pointer, :pointer, :pointer, :pointer], :void

  attach_function :cvSum, [:pointer], CvScalar.by_value

  attach_function :cvTranspose, [:pointer, :pointer], :void

  attach_function :cvReleaseMat, [ :pointer ], :void
  attach_function :cvReleaseData, [ :pointer ], :void

  # cvReleaseImage expects a double-pointer to an IplImage
  attach_function :cvReleaseImageReal, :cvReleaseImage, [ :pointer ], :void
  def self.cvReleaseImage( iplImage )
    #ptr = FFI::MemoryPointer.new :pointer
    #ptr.put_pointer(0, iplImage.to_ptr )
    #cvReleaseImageReal iplImage
  end
end
