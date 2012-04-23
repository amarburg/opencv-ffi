
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

  template<typename _Tp> struct Gray2YB
  {
    typedef _Tp channel_type;

    Gray2YB( int _scaler ) : scaler(_scaler)
    { }

    void operator()(const _Tp* src, _Tp* dst, int n) const
    {
      int scn = 1, dcn = 3;

      // Takes a 1- channel image, always returns a 3-channel 8U BGR image
      n *= scn;

      for( int i = 0; i < n; i += scn, dst += 3 )
      {
        float b = (2.0*src[i]/(1.0*scaler))-1.0;
        float g = -b;
        float r = -b;

        dst[0] = saturate_cast<uint>(b*256); 
        dst[1] = saturate_cast<uint>(g*256);
        dst[2] = saturate_cast<uint>(r*256);
      }
    }

    int scaler;
  };

  template<typename _Tp> struct Gray2RG
  {
    typedef _Tp channel_type;

    Gray2RG( int _scaler ) : scaler(_scaler)
    { }

    void operator()(const _Tp* src, _Tp* dst, int n) const
    {
      int scn = 1, dcn = 3;

      // Takes a 1- channel image, always returns a 3-channel 8U BGR image
      n *= scn;

      for( int i = 0; i < n; i += scn, dst += 3 )
      {
        float r = (2.0*src[i]/(1.0*scaler))-1.0;
        float g = -r;
        float b = 0;

        dst[0] = saturate_cast<uint>(b*256); 
        dst[1] = saturate_cast<uint>(g*256);
        dst[2] = saturate_cast<uint>(r*256);
      }
    }

    int scaler;
  };


  template<typename _Tp> struct GaussianOpponent
  {
    typedef _Tp channel_type;

    GaussianOpponent( int _srccn, int _dstcn, int _blueIdx, int _scaler ) 
      : srccn(_srccn), dstcn(_dstcn), blueIdx(_blueIdx ), scaler( _scaler )
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
        float rf = r/(1.0*scaler), bf = b/(1.0*scaler), gf = g/(1.0*scaler);
        float E   = 0.06*rf +  0.63*gf +  0.27*bf;
        float El  = 0.30*rf +  0.04*gf + -0.35*bf;
        float Ell = 0.34*rf + -0.60*gf +  0.17*bf;
        dst[0] = saturate_cast<_Tp>(E*scaler); 
        dst[1] = saturate_cast<_Tp>(El*scaler); 
        dst[2] = saturate_cast<_Tp>(Ell*scaler);
      }
    }

    int srccn, dstcn, blueIdx, scaler;
  };

  template<typename _Tp> struct HInvariant
  {
    typedef _Tp channel_type;

    HInvariant( int _srccn, int _dstcn, int _blueIdx, int _scaler ) 
      : srccn(_srccn), dstcn(_dstcn), blueIdx(_blueIdx ), scaler( _scaler )
    { }

    void operator()(const _Tp* src, _Tp* dst, int n) const
    {
      int scn = srccn, dcn = dstcn;
      int redIdx = (blueIdx == 0) ? 2 : 0;

      // Takes a 3- or 4- channel image, always returns a 1-channel image
      n *= scn;

      for( int i = 0; i < n; i += scn, dst += 3 )
      {
        _Tp b = src[i+blueIdx], g = src[i+1], r = src[i+redIdx], t3 = src[i+3];
        float rf = r/(1.0*scaler), bf = b/(1.0*scaler), gf = g/(1.0*scaler);
        float E   = 0.06*rf +  0.63*gf +  0.27*bf;
        float El  = 0.30*rf +  0.04*gf + -0.35*bf;
        float Ell = 0.34*rf + -0.60*gf +  0.17*bf;

        float Elx = 1.0, Ellx = 1.0;
        float Ely = 1.0, Elly = 1.0;

        float xx = Ell*Elx - El*Ellx;
        float yy = Ell*Ely - El*Elly;

        float H = 1/(El*El + Ell*Ell) * sqrt(  xx*xx + yy*yy );

        dst[0] = saturate_cast<_Tp>(E*scaler); 
      }
    }

    int srccn, dstcn, blueIdx, scaler;
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
          CvtColorLoop(src, dst, GaussianOpponent<uchar>(scn, dcn, blueIdx,256));
        else if( depth == CV_16U )
          CvtColorLoop(src, dst, GaussianOpponent<ushort>(scn, dcn, blueIdx, 2<<16 ) );
        else
          CvtColorLoop(src, dst, GaussianOpponent<float>(scn, dcn, blueIdx, 1 ));
        break;
      case COLOR_INVARIANCE_BGR2HInvariant:
        CV_Assert( scn == 3 || scn == 4 );
        dcn = 1;
        blueIdx = (code == COLOR_INVARIANCE_BGR2HInvariant) ? 0 : 2;

        _dst.create( sz, CV_MAKETYPE(depth, dcn));
        dst = _dst.getMat();

        if( depth == CV_8U )
          CvtColorLoop(src, dst, HInvariant<uchar>(scn, dcn, blueIdx, 256));
        else if( depth == CV_16U )
          CvtColorLoop(src, dst, HInvariant<ushort>(scn, dcn, blueIdx, 2<<16 ) );
        else
          CvtColorLoop(src, dst, HInvariant<float>(scn, dcn, blueIdx, 1 ));
        break;
       case COLOR_INVARIANCE_Gray2YB:
        CV_Assert( scn == 1 );
        dcn = 3;

        _dst.create( sz, CV_MAKETYPE(CV_8U, 3));
        dst = _dst.getMat();

        if( depth == CV_8U )
          CvtColorLoop(src, dst, Gray2YB<uchar>( 256 ) );
        else if( depth == CV_16U )
          CvtColorLoop(src, dst, Gray2YB<ushort>( 2<<16 ) );
        else
          CvtColorLoop(src, dst, Gray2YB<float>( 1 ) );
        break;
      case COLOR_INVARIANCE_Gray2RG:
        CV_Assert( scn == 1 );
        dcn = 3;

        _dst.create( sz, CV_MAKETYPE(CV_8U, 3));
        dst = _dst.getMat();

        if( depth == CV_8U )
          CvtColorLoop(src, dst, Gray2RG<uchar>( 256 ) );
        else if( depth == CV_16U )
          CvtColorLoop(src, dst, Gray2RG<ushort>( 2<<16 ) );
        else
          CvtColorLoop(src, dst, Gray2RG<float>( 1 ) );
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

