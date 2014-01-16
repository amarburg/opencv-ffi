
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
                     :CV_64FC3,
                     :CV_8UC4, 24,
                     :CV_8SC4, 
                     :CV_16UC4,
                     :CV_16SC4,
                     :CV_32SC4,
                     :CV_32FC4,
                     :CV_64FC4 ]

  ## As present, the type encodes 9 bits of nChannels and 3 bits of typ
  def self.matMagicType( m )
    # Want to cast m.type to an integer
    type = case m.type
           when Integer
             m.type
           when Symbol
             CvMatType[m.type]
           else
             raise "Can't convert #{m.type} (#{m.type.class}) to a numeric OpenCV type"
           end

    type & 0xFFF
  end

  def self.matChannels( m )
    (matMagicType(m) >> 3) + 1
  end

  def self.matDepth( m )
    (matMagicType(m) & 0x07)
  end

  # A bit clumsy
  def self.matType( m )
    CvMatType[ CVFFI::matMagicType( m ) ]
  end

  attach_function :cvAdd, [ :pointer, :pointer, :pointer, :pointer ], :void
  attach_function :cvAddWeighted, [ :pointer, :double, :pointer, :double, :double, :pointer ], :void
  attach_function :cvAddS, [:pointer, CvScalar.by_value, :pointer, :pointer], :void
  attach_function :cvAvg, [:pointer, :pointer], CvScalar.by_value
  attach_function :cvAvgSdv, [:pointer, :pointer, :pointer, :pointer], :void
  attach_function :cvCloneImage, [ :pointer ], IplImage.typed_pointer
  attach_function :cvCloneMat,   [ :pointer ], CvMat.typed_pointer

  enum :cvCmpTypes, [ :CV_CMP_EQ, :CV_CMP_GT, :CV_CMP_GE, :CV_CMP_LT, :CV_CMP_LE, :CV_CMP_NE ]
  attach_function :cvCmp, [:pointer, :pointer, :pointer, :int], :void
  attach_function :cvConvertScale, [:pointer, :pointer, :double, :double], :void

  attach_function :cvCreateMat, [ :int, :int, :cvMatType ], CvMat.typed_pointer
  attach_function :cvCreateMatHeader, [:int, :int, :cvMatType ], CvMat.typed_pointer
  attach_function :cvCreateImage, [ CvSize.by_value, :int, :int ], IplImage.typed_pointer

  attach_function :cvCopy, [ :pointer, :pointer, :pointer ], :void


  attach_function :cvSetImageROI, [:pointer, CvRect.by_value ], :void
  attach_function :cvGetImageROI, [:pointer], CvRect.by_value
  attach_function :cvResetImageROI, [:pointer], :void


  attach_function :cvGEMM, [:pointer, :pointer, :double, :pointer, :double, :pointer, :int], :void

  # CVAPI(CvScalar) cvGet2D( const CvArr* arr, int idx0, int idx1 );
  attach_function :cvGet1D, [ :pointer, :int ], CvScalar.by_value
  attach_function :cvGet2D, [ :pointer, :int, :int ], CvScalar.by_value
  attach_function :cvGet3D, [ :pointer, :int, :int, :int ], CvScalar.by_value

  attach_function :cvGetMat, [ :pointer, :pointer, :pointer, :int ], CvMat.typed_pointer

  attach_function :cvGetReal1D, [ :pointer, :int ], :double
  attach_function :cvGetReal2D, [ :pointer, :int, :int ], :double
  attach_function :cvGetReal3D, [ :pointer, :int, :int, :int ], :double

  attach_function :cvGetSubRect, [ :pointer, :pointer, CvRect.by_value ], CvMat.typed_pointer

  enum :cvInvertTypes, [ :CV_LU, 0,
                         :CV_SVD, 1,
                         :CV_SVD_SYM, 2,
                         :CV_CHOLESKY, 3,
                         :CV_QR, 4,
                         :CV_NORMAL, 16 ]
  attach_function :cvInvert, [:pointer, :pointer, :int], :double

  attach_function :cvLog, [ :pointer, :pointer ], :void

  attach_function :cvMerge, [ :pointer, :pointer, :pointer, :pointer, :pointer ], :void
  attach_function :cvMinMaxLoc, [:pointer, :pointer, :pointer, :pointer,:pointer,:pointer], :void

  enum :cvNormTypes, [ :CV_C, 1,
                       :CV_L1, 2,
                       :CV_L2, 4 ]
  attach_function :real_cvNorm, :cvNorm, [ :pointer, :pointer, :int, :pointer ], :double
  def self.cvNorm( arr1, arr2 = nil, normType = :CV_L2, mask = nil )
    real_cvNorm( arr1, arr2, normType, mask )
  end

  CvDistType = enum :cvDistType, [ :CV_RAND_UNI, 0,
                                   :CV_RAND_NORMAL, 1]
  attach_function :cvRandArr, [:pointer, :pointer, CvDistType, CvScalar.by_value, CvScalar.by_value], :void
  
  # cvRNG is actuall handled by an inline, so fake it out.
  # attach_function :cvRNG, [:int64], :uint64
  # At present all it really does is "launder" an int64 into a uint64
  class CvRNG < NiceFFI::Struct
    layout :x, :uint64
  end
  def self.cvRNG( seed = -1 ); CvRNG.new({:x => seed}); end

  attach_function :cvScaleAdd, [ :pointer, CvScalar.by_value, :pointer, :pointer ], :void
  attach_function :_cvSet, :cvSet,  [ :pointer, CvScalar.by_value, :pointer ], :void
  def self.cvSet( mat, s, mask = nil ); _cvSet( mat, s, mask ); end

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

  attach_function :cvSub, [:pointer, :pointer, :pointer, :pointer], :void
  attach_function :cvSubRS, [:pointer, CvScalar.by_value, :pointer, :pointer ], :void
  attach_function :cvSum, [:pointer], CvScalar.by_value

  attach_function :cvTranspose, [:pointer, :pointer], :void

  attach_function :cvReleaseMat, [ :pointer ], :void

  # cvReleaseMat expects a pointer-to-pointer, which is awkware
  def self.releaseMat( mat )
    ptr = FFI::MemoryPointer.new :pointer
    ptr.put_pointer(0, mat.to_ptr )
    cvReleaseMat ptr
  end

  attach_function :cvReleaseData, [ :pointer ], :void

  # cvReleaseImage expects a double-pointer to an IplImage
  attach_function :cvReleaseImageReal, :cvReleaseImage, [ :pointer ], :void
  def self.cvReleaseImage( iplImage )
    #ptr = FFI::MemoryPointer.new :pointer
    #ptr.put_pointer(0, iplImage.to_ptr )
    #cvReleaseImageReal iplImage
  end
end
