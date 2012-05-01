#ifndef _SIFT_H_
#define _SIFT_H_

#include <opencv2/core/types_c.h>
#include <vector>
#include <opencv2/features2d/features2d.hpp>

typedef struct {
  int nOctaves, nOctaveLayers;

  double threshold, edgeThreshold;
  double magnification;

  int recalculateAngles;
} CvSIFTParams_t;

/* These two functions are C wrappers around OpenCV's "stock" C++ 
 * SIFT functions.  By doing so they're C wrappers around C++ wrappers
 * around C functions.  The functions found in cv_sift.cpp are "pure C"
 * copies of the OpenCV functions.  In reality the C API should just be
 * exposed in OpenCV, with the explicit C++ wrapper around it.
 */
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


