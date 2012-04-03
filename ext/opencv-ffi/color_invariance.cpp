
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include "color_invariance.h"

namespace cv {
  void cvtColorInvariants(InputArray _src, OutputArray _dst, int code, int dcn )
  {
    Mat src = _src.getMat(), dst;
    Size sz = src.size();
    int scn = src.channels(), depth = src.depth(), bidx;

    CV_Assert( depth == CV_8U || depth == CV_16U || depth == CV_32F );

    switch(code) {
      case COLOR_INVARIANCE_FOO:
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

