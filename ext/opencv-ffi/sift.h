
#ifndef _SIFT_H_
#define _SIFT_H_

#include <opencv2/core/types_c.h>
#include <vector>
#include <opencv2/features2d/features2d.hpp>

typedef struct {
  int nOctaves, nOctaveLayers;

  double threshold, edgeThreshold;
  double magnification;
} CvSIFTParams_t;

extern "C" 
void cvSIFTWrapperDetect( const CvArr *img, 
    const CvArr *mask, 
    CvSeq **keypoints,
    CvMemStorage *storage,
    CvSIFTParams_t params );

extern "C"
CvMat *cvSIFTWrapperDetectDescribe( const CvArr *img, 
    const CvArr *mask, 
    CvSeq **keypoints,
    CvMemStorage *storage,
    CvSIFTParams_t params );

CvSeq *KeyPointsToCvSeq( std::vector<cv::KeyPoint> kps, CvMemStorage *storage );

#endif


