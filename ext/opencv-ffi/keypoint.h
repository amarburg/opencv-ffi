

#ifndef _KEYPOINT_H
#define _KEYPOINT_H

#include <opencv2/features2d/features2d.hpp>

typedef struct {
  float x,y,size,angle,response;
  int octave;
} CvKeyPoint_t;

typedef struct {
  CvKeyPoint_t *kps;
  int len;
} CvKeyPoints_t;

extern CvKeyPoint_t KeyPointToKeyPoint_t( const cv::KeyPoint &kp );

#endif 

