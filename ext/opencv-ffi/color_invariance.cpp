
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include "color_invariance.h"

/* Cribbed from imgproc.cpp */
namespace cv {
  template<class Cvt> void CvtColorLoop(const Mat& srcmat, Mat& dstmat, const Cvt& cvt)
  {
    typedef typename Cvt::channel_type _Tp;
    Size sz = srcmat.size();
    const uchar* src = srcmat.data;
    uchar* dst = dstmat.data;
    size_t srcstep = srcmat.step, dststep = dstmat.step;

    if( srcmat.isContinuous() && dstmat.isContinuous() )
    {
      sz.width *= sz.height;
      sz.height = 1;
    }    

    for( ; sz.height--; src += srcstep, dst += dststep )
      cvt((const _Tp*)src, (_Tp*)dst, sz.width);
  }

  template<typename _Tp> struct GaussianOpponent
  {
    typedef _Tp channel_type;

    GaussianOpponent( int _srccn, int _dstcn, int _blueIdx ) : srccn(_srccn), dstcn(_dstcn), blueIdx(_blueIdx )
    { }

    void operator()(const _Tp* src, _Tp* dst, int n) const
    {
      int scn = srccn, dcn = dstcn;
      int redIdx = (blueIdx == 0) ? 2 : 0;

      // Takes a 3- or 4- channel image, always returns a 3-channel image
      n *= scn;

      for( int i = 0; i < n; i += scn, dst += 3 )
      {
        _Tp b = src[i+blueIdx], g = src[i+1], r = src[i+redIdx], t3 = src[i+3];
        float E   = 0.06*r + 0.63*g + 0.27*b;
        float El  = 0.30*r + 0.04*g + -0.35*b;
        float Ell = 0.34*r + -0.60*g + 0.17*b;
        dst[0] = saturate_cast<_Tp>(E); 
        dst[1] = saturate_cast<_Tp>(El); 
        dst[2] = saturate_cast<_Tp>(Ell);
      }
    }

    int srccn, dstcn, blueIdx;
  };

  void cvtColorInvariants(InputArray _src, OutputArray _dst, int code, int dcn )
  {
    Mat src = _src.getMat(), dst;
    Size sz = src.size();
    int scn = src.channels(), depth = src.depth(), bidx;
    int blueIdx;

    CV_Assert( depth == CV_8U || depth == CV_16U || depth == CV_32F );

    switch(code) {
      case COLOR_INVARIANCE_PASSTHROUGH:
        dst = src;
        break;
      case COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT:
      case COLOR_INVARIANCE_RGB2GAUSSIAN_OPPONENT:
        CV_Assert( scn == 3 || scn == 4 );
        dcn = 3;
        blueIdx = (code == COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT) ? 0 : 2;

        _dst.create( sz, CV_MAKETYPE(depth, dcn));
        dst = _dst.getMat();

        if( depth == CV_8U )
          CvtColorLoop(src, dst, GaussianOpponent<uchar>(scn, dcn, blueIdx));
        else if( depth == CV_16U )
          CvtColorLoop(src, dst, GaussianOpponent<ushort>(scn, dcn, blueIdx));
        else
          CvtColorLoop(src, dst, GaussianOpponent<float>(scn, dcn, blueIdx));
        break;
      default:
        CV_Error( CV_StsBadFlag, "Unknown/unsupported color conversion code" );
    }

  }
}


extern "C" {
  /* Lifted from imgproc/cvtColor */
  void cvCvtColorInvariants( const CvArr *srcarr, CvArr *dstarr, int code )
  {
    cv::Mat src = cv::cvarrToMat(srcarr), dst0 = cv::cvarrToMat(dstarr), dst = dst0;
    CV_Assert( src.depth() == dst.depth() );

    cv::cvtColorInvariants(src, dst, code, dst.channels());
    CV_Assert( dst.data == dst0.data );
  }
}

