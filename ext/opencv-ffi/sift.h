
#ifndef _SIFT_H_
#define _SIFT_H_

#include <opencv2/core/types_c.h>

typedef struct {
  int nOctaves, nOctaveLayers;

  double threshold, edgeThreshold;
  double magnification;
} CvSIFTParams_t;

extern "C" 
void cvSIFTDetect( const CvArr *img, 
                   const CvArr *mask, 
                   CvSeq **keypoints,
                    CvMemStorage *storage,
                    CvSIFTParams_t params );

extern "C"
CvMat *cvSIFTDetectDescribe( const CvArr *img, 
    const CvArr *mask, 
    CvSeq **keypoints,
    CvMemStorage *storage,
    CvSIFTParams_t params );

#endif


