
#include <stdio.h>

#include <assert.h>
#include <opencv2/core/core_c.h>

#include "keypoint.h"
#include "sift.h"

using namespace cv;


CvSeq *KeyPointsToCvSeq( vector<KeyPoint> kps, CvMemStorage *storage )
{
  CvSeq *seq = cvCreateSeq( 0, sizeof( CvSeq ), sizeof( CvKeyPoint_t ), storage );
  
  CvSeqWriter writer;
  cvStartAppendToSeq( seq, &writer );
  for( vector<KeyPoint>::iterator itr = kps.begin(); itr != kps.end(); itr++ ) {
    CvKeyPoint_t kp = KeyPointToKeyPoint_t( *itr );
    CV_WRITE_SEQ_ELEM( kp, writer );
  }
  cvEndWriteSeq( &writer );

  assert( kps.size() == seq->total );

  return seq;
}


// TODO:  The irony here is that the SIFT implementation is largely in
//  C, and has a thin C++ wrapper around it, but no C API is exposed...


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

  *keypoints = KeyPointsToCvSeq( kps, storage );
}

// Both detection and description
extern "C"
CvMat *cvSIFTDetectDescribe( const CvArr *img, 
    const CvArr *mask, 
    CvSeq **keypoints,
    CvMemStorage *storage,
    CvSIFTParams_t params )
{
  SIFT::CommonParams   commonParams( params.nOctaves, params.nOctaveLayers );
  SIFT::DetectorParams detectorParams( params.threshold, params.edgeThreshold );
  SIFT::DescriptorParams descriptorParams( params.magnification, true, true );

  // Constructor for both detection and description
  SIFT sift( commonParams, detectorParams, descriptorParams );

  vector <KeyPoint> kps;
  Mat descs(1,1,CV_32FC1);
  CvMat stub;
  Mat imgMat( cvGetMat( img, &stub ) );
  Mat maskMat;
  if( mask )
    maskMat = cvGetMat( mask, &stub );

  sift( imgMat, maskMat, kps, descs, false );

  printf("Keypoints %d, descriptors %d x %d\n", kps.size(), descs.rows, descs.cols );

  // Unpack...
  *keypoints = KeyPointsToCvSeq( kps, storage );
  CvMat desc_mat = descs;
  return cvCloneMat( &desc_mat );
}



//
// There's a third option here, which is just describe (presumably using 
// keypoints provided by the user...)

