
#include <opencv2/core/core_c.h>

#include "keypoint.h"

using namespace cv;

typedef struct {
  int nOctaves, nOctaveLayers;

  double threshold, edgeThreshold;
  double magnification;
} CvSIFTParams_t;



// Keypoint detection only
extern "C" 
void cvSIFTDetect( const CvArr *img, 
                   const CvArr *mask, 
                   CvSeq **keypoints,
                    CvMemStorage *storage,
                    CvSIFTParams_t params )
{
  // Detector-specific constructor
  SIFT sift( params.threshold, params.edgeThreshold, params.nOctaves, params.nOctaveLayers );

  vector<KeyPoint> kps;
  CvMat stub;
  Mat imgMat( cvGetMat( img, &stub ) );
  Mat maskMat;
  if( mask )
    maskMat = cvGetMat( mask, &stub );

  sift( imgMat, maskMat, kps );

  CvSeq *seq = cvCreateSeq( 0, sizeof( CvSeq ), sizeof( CvKeyPoint_t ), storage );
  
  CvSeqWriter writer;
  cvStartAppendToSeq( seq, &writer );
  for( vector<KeyPoint>::iterator itr = kps.begin(); itr != kps.end(); itr++ ) {
    CV_WRITE_SEQ_ELEM( KeyPointToKeyPoint_t( *itr ), writer );
  }

  *keypoints = seq;
}

// Both detection and description
extern "C"
void cvSIFTDetectDescribe( const CvArr *img, 
    const CvArr *mask, 
    CvSeq **keypoints,
    CvMat *descriptors,
    CvMemStorage *storage,
    CvSIFTParams_t params )
{
  SIFT::CommonParams   commonParams( params.nOctaves, params.nOctaveLayers );
  SIFT::DetectorParams detectorParams( params.threshold, params.edgeThreshold );
  SIFT::DescriptorParams descriptorParams( params.magnification, true, true );

  // Constructor for both detection and description
  SIFT sift( commonParams, detectorParams, descriptorParams );

  vector <KeyPoint> kps;
  Mat descs;
  CvMat stub;
  Mat imgMat( cvGetMat( img, &stub ) );
  Mat maskMat( cvGetMat( mask, &stub ) );
  sift( imgMat, maskMat, kps, descs );

  // Unpack...
}


