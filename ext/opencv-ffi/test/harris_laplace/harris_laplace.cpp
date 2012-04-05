
#include <iostream>


#include "harris_laplace.hpp"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;


static void harrisLaplaceCpp( Mat &image )
{
  HarrisLaplaceFeatureDetector laplace( 6, 0.01, 0.01, 5000, 4 );
  vector<KeyPoint> keypoints;

  laplace.detect( image, keypoints );

  cout << "C++ Harris-Laplace detected " << keypoints.size() << endl;
}

static void harrisLaplaceC( Mat &image )
{
  CvMat _image = image;
  CvMemStorage *storage = cvCreateMemStorage(0);

  CvHarrisLaplaceParams params;
  params.numOctaves = 6;
  params.corn_thresh = 0.01;
  params.DOG_thresh = 0.01;
  params.maxCorners = 5000;
  params.num_layers = 4;

  CvSeq *seq = cvHarrisLaplaceDetector( &_image, storage, params );


  cout << "C Harris-Laplace detected " << seq->total << endl;

  cvClearSeq( seq );
  cvReleaseMemStorage( &storage );
}

static void harrisAffineCpp( Mat &image )
{
  HarrisAffineFeatureDetector  affine(  6, 0.01, 0.01, 5000, 4 );
  vector<Elliptic_KeyPoint> elliptic_keypoints;

  affine.detect( image, elliptic_keypoints );

  cout << "C++ Harris-Affine detected " << elliptic_keypoints.size() << endl;
}

static void harrisAffineC( Mat &image )
{
  CvMat _image = image;
  CvMemStorage *storage = cvCreateMemStorage(0);

  CvHarrisAffineParams params;
  params.numOctaves = 6;
  params.corn_thresh = 0.01;
  params.DOG_thresh = 0.01;
  params.maxCorners = 5000;
  params.num_layers = 4;

  CvSeq *seq = cvHarrisAffineDetector( &_image, storage, params );

  cout << "C Harris-Affine detected " << seq->total << endl;

  cvClearSeq( seq );
  cvReleaseMemStorage( &storage );
}



int main()
{
  Mat image = imread("../../../../test/test_files/images/IMG_7088_small.JPG", 0 );

  harrisLaplaceCpp( image );
  harrisLaplaceC( image );
  harrisAffineCpp( image );
  harrisAffineC( image );

  // Cleanup and exit
  return 0;
}

