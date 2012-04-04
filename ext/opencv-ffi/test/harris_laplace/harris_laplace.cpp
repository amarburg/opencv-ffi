
#include <stdio.h>

#include "harris_laplace.hpp"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;

int main()
{
  Mat image = imread("../../../../test/test_files/images/IMG_7088_small.JPG", 0 );

  HarrisLaplaceFeatureDetector laplace( 6, 0.01, 0.01, 5000, 4 );
  HarrisAffineFeatureDetector  affine(  6, 0.01, 0.01, 5000, 4 );
  vector<KeyPoint> keypoints;
  vector<Elliptic_KeyPoint> elliptic_keypoints;

  laplace.detect( image, keypoints );
  affine.detect( image, elliptic_keypoints );

  printf("HarrisLaplace Detected %d features.\n", keypoints.size() );
  printf("HarrisAffine detected %d features.\n", elliptic_keypoints.size() );

  // Cleanup and exit
  return 0;
}

