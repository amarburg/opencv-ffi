#ifndef _CV_SIFT_H_
#define _CV_SIFT_H_

#include <opencv2/core/types_c.h>
#include <vector>

#include "sift.h"

/* These are "pure C" versions of OpenCV's SIFT functions.
 * They aren't actually pure C, as they use some C++ functionality
 * internally ... courtesy of the original code.
 */
extern "C"  {
  CvSeq *cvSIFTDetect( const CvArr *imageArr, const CvArr *maskArr, 
      CvMemStorage *storage, CvSIFTParams_t params );

  CvSeq *cvSIFTDetectDescribe( const CvArr *imageArr, const CvArr *maskArr, 
      CvMemStorage *storage, CvSIFTParams_t params,
      CvSeq *features CV_DEFAULT(NULL) );
#endif


