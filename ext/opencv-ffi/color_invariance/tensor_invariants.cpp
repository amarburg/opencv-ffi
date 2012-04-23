
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <stdio.h>

using namespace std;
using namespace cv;

#define KSIZE 1

#define Pixel Vec3f

double sdot( const Pixel &a, const Pixel &b )
{
  return a(0)*b(0)+ a(1)*b(1)+ a(2)*b(2);
}

// Implements the algorithms in section II.c of van de Weijer, Gevers and Smeulders
// "Robust Photometric Invariant Features From the Color Tensor"
// DOI:  10.1109/TIP.2005.860343
//
void generateSQuasiInvariant( Mat &src, Mat &scx, Mat &scy )
{
  Size sz = src.size();

  CV_Assert( src.channels() == 3 );
  CV_Assert( src.depth() == CV_32F );

  scx.create( sz, CV_MAKETYPE( CV_32F, 3 ) );
  scy.create( sz, CV_MAKETYPE( CV_32F, 3 ) );

  CV_Assert( src.type() == scx.type() );
  CV_Assert( src.type() == scy.type() );

  //cout << "Size is " << sz.width << "x" << sz.height << endl;

  Mat fx( sz, CV_32FC(3) );
  Mat fy( sz, CV_32FC(3) );

  Mat sx( sz, CV_MAKETYPE( CV_32F, 3 ) );
  Mat sy( sz, CV_MAKETYPE( CV_32F, 3 ) );

  Ptr<FilterEngine> filter_x = createDerivFilter( src.type(), fx.type(), 1, 0,  KSIZE );
  Ptr<FilterEngine> filter_y = createDerivFilter( src.type(), fy.type(), 0, 1,  KSIZE );

  filter_x->apply( src, fx );
  filter_y->apply( src, fy );

  for( int i = 0; i < sz.height; i++ ) {
    for( int j = 0; j < sz.width; j++ ) {
      Pixel fhat = src.at<Pixel>( i,j );
      float fnorm = 1.0/norm(fhat);
      fhat *= fnorm;

      sx.at<Pixel>( i,j ) = fhat * sdot( fx.at<Pixel>(i,j), fhat );
      scx.at<Pixel>(i,j ) = (fx.at<Pixel>(i,j) - sx.at<Pixel>(i,j)) * fnorm;
      sy.at<Pixel>( i,j ) = fhat * sdot( fy.at<Pixel>(i,j), fhat );
      scy.at<Pixel>(i,j ) = (fy.at<Pixel>(i,j) - sy.at<Pixel>(i,j)) * fnorm;
    }
  }

  cout << "Complete" << endl;
}



extern "C" {
  void cvGenerateSQuasiInvariant( CvMat *srcarr, CvMat *scx, CvMat *scy )
  {
    Mat src = cvarrToMat(srcarr);
    Mat cvtSrc;

    // Input must be cast to 32FC3
    CV_Assert( src.channels() == 3 );
    switch( src.depth() ) {
      case CV_8U:
        src.convertTo( cvtSrc, CV_32F, 1/256.0, 0 );
        break;
      case CV_32F:
        cvtSrc = src;
        break;
      default:
        cout << "cvGenerateSQuasiInvariant cannot deal with type " << src.depth() << endl;
    }

    Mat scxMat = cvarrToMat(scx), dstx;
    Mat scyMat = cvarrToMat(scy), dsty;

    generateSQuasiInvariant( cvtSrc, dstx, dsty );

    // Cast back to scx, scy type
    switch( scxMat.depth() ) {
      case CV_8U:
        dstx.convertTo( scxMat, CV_8U, 256.0, 0 );
        dsty.convertTo( scyMat, CV_8U, 256.0, 0 );
        break;
      case CV_32F:
        // Strictly speaking, you should be able to set scx.data == dstx
        // but the syntax escapes me...
        dstx.copyTo( scxMat );
        dsty.copyTo( scyMat );
        break;
      default:
        cout << "cvGenerateSQuasiInvariant cannot deal with type " << scxMat.depth() << endl;
    }

    // This will catch if dstx,dsty are reallocated in generateSQuasiInvariant
    //CV_Assert( dstx.data == dstx1.data );
    //CV_Assert( dsty.data == dsty0.data );
  }

}

