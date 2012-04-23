
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include <iostream>
#include <stdio.h>

using namespace std;

#define KSIZE 1

#define Pixel Vec3f

namespace cv {

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

  //Ptr<FilterEngine> filter_x = createDerivFilter( src.type(), fx.type(), 1, 0,  KSIZE );
  //Ptr<FilterEngine> filter_y = createDerivFilter( src.type(), fy.type(), 0, 1,  KSIZE );
  //filter_x->apply( src, fx );
  //filter_y->apply( src, fy );

  Sobel( src, fx, CV_32F, 1, 0, CV_SCHARR );
  Sobel( src, fy, CV_32F, 0, 1, CV_SCHARR );

  for( int i = 0; i < sz.height; i++ ) {
    for( int j = 0; j < sz.width; j++ ) {
      Pixel fhat = src.at<Pixel>( i,j );
      float fnorm = 1.0/norm(fhat);
      fhat *= fnorm;

      sx.at<Pixel>( i,j ) = fhat * sdot( fx.at<Pixel>(i,j), fhat );
      scx.at<Pixel>(i,j ) = (fx.at<Pixel>(i,j) - sx.at<Pixel>(i,j)); 
      if( i == 100 and j == 108 ) {
        Pixel s = sx.at<Pixel>(i,j), sc = scx.at<Pixel>(i,j), f = fx.at<Pixel>(i,j);

        cout << "fhat " << fhat[0] << "," << fhat[1] << "," << fhat[2] <<endl;
        cout << "fx " << f[0] << "," << f[1] << "," << f[2] <<endl;
        cout << "sx  " << s[0] << "," << s[1] << "," << s[2] << endl;
        cout << "scx " << sc[0] << "," << sc[1] << "," << sc[2] << endl;
      }

      sy.at<Pixel>( i,j ) = fhat * sdot( fy.at<Pixel>(i,j), fhat );
      scy.at<Pixel>(i,j ) = (fy.at<Pixel>(i,j) - sy.at<Pixel>(i,j)); 
    }
  }

  cout << "Complete" << endl;
}

static void quasiInvariantHarris( const Mat &quasiX, const Mat &quasiY, Mat &_dst, double k )
{
  _dst.create( quasiX.size(), CV_32F );
  CV_Assert( quasiX.size() == quasiY.size() );

  Size size = quasiX.size();

  // Eschew the faster pointer access for the more understandable .at<>()
  // for now...
  //
  //if( quasiX.isContinuous() && quasiY.isContinuous() && _dst.isContinuous() )
  //{
  //  size.width *= size.height;
  //  size.height = 1;
  // }

  for( int i = 0; i < size.height; i++ )
  {
    for( int j = 0; j < size.width; j++ )
    {
      Pixel x = quasiX.at<Pixel>(i,j);
      Pixel y = quasiY.at<Pixel>(i,j);

      float xx = sdot( x, x ), yy = sdot( y,y ), xy = sdot(x,y);
      _dst.at<float>(i,j) = xx*yy - xy*xy - k*(xx+yy)*(xx+yy);
    }
  }

}

template<typename T> struct greaterThanPtr
{
      bool operator()(const T* a, const T* b) const { return *a > *b; }
};

// Lift of the stock goodFeaturesToTrack, using quasiinvariants for Harris calculation
void quasiInvariantFeaturesToTrack( const Mat &quasiX, 
    const Mat &quasiY, 
    OutputArray _corners,
    int maxCorners, double qualityLevel, double minDistance,
    const Mat &mask, 
    bool useHarrisDetector,
    double harrisK )
{

  CV_Assert( qualityLevel > 0 && minDistance >= 0 && maxCorners >= 0 );
  CV_Assert( quasiX.size() == quasiY.size() );

  Mat eig, tmp;

  if( useHarrisDetector )
    quasiInvariantHarris( quasiX, quasiY, eig, harrisK );
  //else
  //  cornerMinEigenVal( image, eig, blockSize, 3 );

  double maxVal = 0;
  minMaxLoc( eig, 0, &maxVal, 0, 0, mask );
  threshold( eig, eig, maxVal*qualityLevel, 0, THRESH_TOZERO );
  dilate( eig, tmp, Mat());

  Size imgsize = quasiX.size();

  vector<const float*> tmpCorners;

  // collect list of pointers to features - put them into temporary image
  for( int y = 1; y < imgsize.height - 1; y++ )
  {
    const float* eig_data = (const float*)eig.ptr(y);
    const float* tmp_data = (const float*)tmp.ptr(y);
    const uchar* mask_data = mask.data ? mask.ptr(y) : 0;

    for( int x = 1; x < imgsize.width - 1; x++ )
    {
      float val = eig_data[x];
      if( val != 0 && val == tmp_data[x] && (!mask_data || mask_data[x]) )
        tmpCorners.push_back(eig_data + x);
    }
  }

  sort( tmpCorners, greaterThanPtr<float>() );
  vector<Point2f> corners;
  size_t i, j, total = tmpCorners.size(), ncorners = 0;

  if(minDistance >= 1)
  {
    // Partition the image into larger grids
    int w = quasiX.cols;
    int h = quasiY.rows;

    const int cell_size = cvRound(minDistance);
    const int grid_width = (w + cell_size - 1) / cell_size;
    const int grid_height = (h + cell_size - 1) / cell_size;

    std::vector<std::vector<Point2f> > grid(grid_width*grid_height);

    minDistance *= minDistance;

    for( i = 0; i < total; i++ )
    {
      int ofs = (int)((const uchar*)tmpCorners[i] - eig.data);
      int y = (int)(ofs / eig.step);
      int x = (int)((ofs - y*eig.step)/sizeof(float));

      bool good = true;

      int x_cell = x / cell_size;
      int y_cell = y / cell_size;
      int x1 = x_cell - 1;
      int y1 = y_cell - 1;
      int x2 = x_cell + 1;
      int y2 = y_cell + 1;

      // boundary check
      x1 = std::max(0, x1);
      y1 = std::max(0, y1);
      x2 = std::min(grid_width-1, x2);
      y2 = std::min(grid_height-1, y2);

      for( int yy = y1; yy <= y2; yy++ )
      {
        for( int xx = x1; xx <= x2; xx++ )
        {   
          vector <Point2f> &m = grid[yy*grid_width + xx];

          if( m.size() )
          {
            for(j = 0; j < m.size(); j++)
            {
              float dx = x - m[j].x;
              float dy = y - m[j].y;

              if( dx*dx + dy*dy < minDistance )
              {
                good = false;
                goto break_out;
              }
            }
          }                
        }
      }

break_out:

      if(good)
      {
        // printf("%d: %d %d -> %d %d, %d, %d -- %d %d %d %d, %d %d, c=%d\n",
        //    i,x, y, x_cell, y_cell, (int)minDistance, cell_size,x1,y1,x2,y2, grid_width,grid_height,c);
        grid[y_cell*grid_width + x_cell].push_back(Point2f((float)x, (float)y));

        corners.push_back(Point2f((float)x, (float)y));
        ++ncorners;

        if( maxCorners > 0 && (int)ncorners == maxCorners )
          break;
      }
    }
  }
  else
  {
    for( i = 0; i < total; i++ )
    {
      int ofs = (int)((const uchar*)tmpCorners[i] - eig.data);
      int y = (int)(ofs / eig.step);
      int x = (int)((ofs - y*eig.step)/sizeof(float));

      corners.push_back(Point2f((float)x, (float)y));
      ++ncorners;
      if( maxCorners > 0 && (int)ncorners == maxCorners )
        break;
    }
  }

  Mat(corners).convertTo(_corners, _corners.fixedType() ? _corners.type() : CV_32F);

  /*
     for( i = 0; i < total; i++ )
     {
     int ofs = (int)((const uchar*)tmpCorners[i] - eig.data);
     int y = (int)(ofs / eig.step);
     int x = (int)((ofs - y*eig.step)/sizeof(float));

     if( minDistance > 0 )
     {
     for( j = 0; j < ncorners; j++ )
     {
     float dx = x - corners[j].x;
     float dy = y - corners[j].y;
     if( dx*dx + dy*dy < minDistance )
     break;
     }
     if( j < ncorners )
     continue;
     }

     corners.push_back(Point2f((float)x, (float)y));
     ++ncorners;
     if( maxCorners > 0 && (int)ncorners == maxCorners )
     break;
     }
     */
}

}

using namespace cv;


extern "C" {
  void cvGenerateSQuasiInvariant( CvMat *srcarr, CvMat *scx, CvMat *scy )
  {
    Mat src = cvarrToMat(srcarr);
    Mat cvtSrc;

    // Input must be cast to 32FC3
    CV_Assert( src.channels() == 3 );
    switch( src.depth() ) {
      case CV_8U:
        src.convertTo( cvtSrc, CV_32F, 1.0, 0 );
        break;
      case CV_32F:
        cvtSrc = src;
        break;
      default:
        cout << "cvGenerateSQuasiInvariant cannot deal with type " << src.depth() << endl;
    }

    Mat scxMat = cvarrToMat(scx), dstx;
    Mat scyMat = cvarrToMat(scy), dsty;

    cv::generateSQuasiInvariant( cvtSrc, dstx, dsty );

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

  void cvQuasiInvariantFeaturesToTrack( const Mat *_quasiX, const Mat *_quasiY, 
      CvPoint2D32f* _corners, int *_corner_count,
      double quality_level, double min_distance,
      const void* _maskImage, 
      int use_harris, double harris_k )
  {
    cv::Mat imageX = cv::cvarrToMat(_quasiX), 
            imageY = cv::cvarrToMat(_quasiY), 
            mask;
    cv::vector<cv::Point2f> corners;

    if( _maskImage )
      mask = cv::cvarrToMat(_maskImage);

    CV_Assert( _corners && _corner_count );
    cv::quasiInvariantFeaturesToTrack( imageX, imageY, corners, *_corner_count, quality_level,
        min_distance, mask, use_harris != 0, harris_k );

    size_t i, ncorners = corners.size();
    for( i = 0; i < ncorners; i++ ) {
      _corners[i] = corners[i];
    }
    *_corner_count = (int)ncorners;
  }

}

