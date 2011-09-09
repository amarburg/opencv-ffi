
require 'opencv-ffi/core/library'
require 'opencv-ffi/core/types'

module CVFFI

  enum :cvMatType, [ :CV_8U, 0,
                     :CV_8UC1, 0,
                     :CV_8S, 
                     :CV_16U,
                     :CV_16S,
                     :CV_32S,
                     :CV_32F,
                     :CV_64F,
                     :CV_USRTYPE1,
                     :CV_8UC2, 8,
                     :CV_8SC2, 9 ]

  ## As present, the type encodes 9 bits of nChannels and 3 bits of typ
  def self.matMagicType( m )
    m.type & 0xFFF
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


  attach_function :cvCreateMat, [ :int, :int, :cvMatType ], CvMat.typed_pointer
  attach_function :cvCreateImage, [ CvSize.by_value, :int, :int ], IplImage.typed_pointer

  attach_function :cvCloneImage, [ :pointer ], IplImage.typed_pointer
  attach_function :cvCloneMat,   [ :pointer ], CvMat.typed_pointer

  attach_function :cvCopy, [ :pointer, :pointer, :pointer ], :void
  attach_function :cvSet,  [ :pointer, CvScalar.by_value, :pointer ], :void

  attach_function :cvSetImageROI, [:pointer, CvRect.by_value ], :void
  attach_function :cvGetImageROI, [:pointer], CvRect.by_value
  attach_function :cvResetImageROI, [:pointer], :void

  # CVAPI(CvScalar) cvGet2D( const CvArr* arr, int idx0, int idx1 );
  attach_function :cvGet1D, [ :pointer, :int ], CvScalar.by_value
  attach_function :cvGet2D, [ :pointer, :int, :int ], CvScalar.by_value
  attach_function :cvGet3D, [ :pointer, :int, :int, :int ], CvScalar.by_value

  attach_function :cvSet1D, [ :pointer, :int, CvScalar.by_value ], :void
  attach_function :cvSet2D, [ :pointer, :int, :int, CvScalar.by_value ], :void
  attach_function :cvSet3D, [ :pointer, :int, :int, :int, CvScalar.by_value ], :void

  attach_function :cvGetReal2D, [ :pointer, :int, :int ], :double
end
