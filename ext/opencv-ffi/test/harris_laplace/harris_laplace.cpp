
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

  cout << "Harris-Laplace detected " << keypoints.size() << endl;
}

static void harrisAffineCpp( Mat &image )
{
  HarrisAffineFeatureDetector  affine(  6, 0.01, 0.01, 5000, 4 );
  vector<Elliptic_KeyPoint> elliptic_keypoints;

  affine.detect( image, elliptic_keypoints );

  cout << "Harris-Affine detected " << elliptic_keypoints.size() << endl;
}



int main()
{
  Mat image = imread("../../../../test/test_files/images/IMG_7088_small.JPG", 0 );

  harrisLaplaceCpp( image );
  harrisAffineCpp( image );

  // Cleanup and exit
  return 0;
}

