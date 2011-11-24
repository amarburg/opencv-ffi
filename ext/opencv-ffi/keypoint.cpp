

#include <opencv2/features2d/features2d.hpp>

#include "keypoint.h"

using namespace cv;

CvKeyPoint_t KeyPointToKeyPoint_t( const KeyPoint &kp )
{
  CvKeyPoint_t keypoint;

  keypoint.x = kp.pt.x;
  keypoint.y = kp.pt.y;
  keypoint.size = kp.size;
  keypoint.angle = kp.angle;
  keypoint.response = kp.response;
  keypoint.octave = kp.octave;

  return keypoint;
}
