#include <stdio.h>

#include "sift.h"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;

// The main function!
int main()
{
  IplImage *img = cvLoadImage("../../../test/test_files/images/IMG_7088_small.JPG", CV_LOAD_IMAGE_GRAYSCALE );
  CvSeq *kps;
  CvMemStorage *mem_storage = cvCreateMemStorage( 0 );
  CvSIFTParams_t params;

  params.nOctaves = 1;
  params.nOctaveLayers = 5;
  params.threshold = 0.04;
  params.edgeThreshold = 10.0;
  params.magnification = 30.0;

  // Create an instance of SIFT
  cvSIFTDetect( img, NULL,  &kps, mem_storage, params );

  printf("Detected %d features.\n", kps->total );

  // Cleanup and exit
  return 0;
}

