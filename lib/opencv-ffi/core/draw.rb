
require 'opencv-ffi/core/library'
require 'opencv-ffi/core/types'

module CVFFI

  CvFontDefines = enum [:CV_FONT_HERSHEY_SIMPLEX, 0,
        :CV_FONT_HERSHEY_PLAIN,
        :CV_FONT_HERSHEY_DUPLEX,
        :CV_FONT_HERSHEY_COMPLEX,
        :CV_FONT_HERSHEY_TRIPLEX,
        :CV_FONT_HERSHEY_COMPLEX_SMALL,
        :CV_FONT_HERSHEY_SCRIPT_SIMPLEX,
        :CV_FONT_HERSHEY_SCRIPT_COMPLEX,
        :CV_FONT_NORMAL, 8,
        :CV_FONT_ITALIC, 16 ]

  enum [:CV_AA, 16]

  class CvFont < NiceFFI::Struct
    layout :nameFont, :string,
           :color,    CvScalar,
           :font_face, :int,
           :ascii,     :pointer,
           :greek,     :pointer,
           :cyrillic,  :pointer,
           :hscale,    :float,
           :vscale,    :float,
           :shear,     :float,
           :thickness, :int,
           :dx,        :float,
           :line_type, :int
  end

  # CVAPI(void)  cvCircle( CvArr* img, 
  #                        CvPoint center, 
  #                        int radius,
  #                        CvScalar color, 
  #                        int thickness CV_DEFAULT(1),
  #                        int line_type CV_DEFAULT(8), 
  #                        int shift CV_DEFAULT(0));
  attach_function :cvCircle, [ :pointer, CvPoint.by_value, :int,
                               CvScalar.by_value, :int, :int, :int ], :void

  attach_function :cvGetTextSize, [ :string, :pointer, :pointer, :pointer ], :void
  
  # CVAPI(void)  cvInitFont( CvFont* font, int font_face,
  #                          double hscale, double vscale,
  #                          double shear CV_DEFAULT(0),
  #                          int thickness CV_DEFAULT(1),
  #                          int line_type CV_DEFAULT(8));
  attach_function :cvInitFont, [:pointer, CvFontDefines, :double, :double, :double, :int, :int ], :void
  #attach_function :cvFont, [:double, :int ], CvFont.by_value
  
  # CVAPI(void)  cvLine( CvArr* img, 
  #                      CvPoint pt1, 
  #                      CvPoint pt2,
  #                      CvScalar color, 
  #                      int thickness CV_DEFAULT(1),
  #                      int line_type CV_DEFAULT(8), 
  #                      int shift CV_DEFAULT(0) );
  attach_function :cvLine, [ :pointer, CvPoint.by_value, CvPoint.by_value,
                              CvScalar.by_value, :int, :int, :int ], :void

  attach_function :cvPutText, [ :pointer, :string, 
                                CvPoint.by_value, :pointer, 
                                CvScalar.by_value ], :void
end
