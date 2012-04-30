
#ifndef _CV_SIFT_H_
#define _CV_SIFT_H_

#include <opencv2/core/types_c.h>
#include <vector>

#include "sift.h"

//typedef struct {
//  int nOctaves, nOctaveLayers;
//
//  double threshold, edgeThreshold;
//  double magnification;
//} CvSIFTParams_t;

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

CvSeq *KeyPointsToCvSeq( std::vector<cv::KeyPoint> kps, CvMemStorage *storage );
#endif


