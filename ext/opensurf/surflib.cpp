
#include <opencv2/core/types_c.h>
#include <opencv2/features2d/features2d.hpp>
#include "surflib.h"

#include <stdio.h>

typedef struct {
  char upright;
  int octaves, intervals, init_sample;
  float thres;
} OpenSURFParams_t;

typedef struct {
  CvPoint pt;
  float scale;
  float orientation;
  int laplacian;
  float descriptor[64];
} OpenSURFPoint_t;

/* "constructor" for OpenSURFPoint_t */

/* Ape the existing OpenCV interface a bit... */
extern "C" 
CvSeq *openSurfDetect( IplImage *img,
    CvMemStorage *storage,
    OpenSURFParams_t params )
{
  std::vector<Ipoint> ipts;

  surfDet( img, ipts, params.octaves, params.intervals, params.init_sample, params.thres );

  /* Now unpack the ipts to keypoints */
  CvSeq *points = cvCreateSeq( 0, sizeof(CvSeq), sizeof(OpenSURFPoint_t), storage );

  for( std::vector<Ipoint>::iterator i = ipts.begin(); i != ipts.end(); i++ ) {
    // TODO.  Impedence mismatch trying to match CVSurf's "size" and "hessian" 
    OpenSURFPoint_t point;
    point.pt.x = (*i).x;
    point.pt.y = (*i).y;
    point.scale = (*i).scale;
    point.orientation = (*i).orientation;
    point.laplacian = (*i).laplacian;

    cvSeqPush( points, &point );
  }

  return points;
}


extern "C"
CvSeq *openSurfDescribe( IplImage *img, CvSeq *points,
                         OpenSURFParams_t params )
{
  /* Repack the CvSeq to ipts */
  std::vector<Ipoint> ipts;

  CvSeqReader reader;
  cvStartReadSeq( points, &reader, 0 );
  for( int i = 0; i < points->total; i++ ) {
    OpenSURFPoint_t *point = (OpenSURFPoint_t *)reader.ptr;
    Ipoint ip;

    ip.x = point->pt.x;
    ip.y = point->pt.y;
    ip.scale = point->scale;
    ip.orientation = point->orientation;
    ip.laplacian = point->laplacian;

    ipts.push_back(ip);

    CV_NEXT_SEQ_ELEM( points->elem_size, reader );
  }

  surfDes( img, ipts, params.upright );

  for(unsigned int i = 0; i < ipts.size(); i++ ) {
    Ipoint pt( ipts[i] );
    OpenSURFPoint_t *point = (OpenSURFPoint_t *)cvGetSeqElem( points, i );
    point->pt.x = pt.x;
    point->pt.y = pt.y;
    point->scale = pt.scale;
    point->orientation = pt.orientation;
    point->laplacian = pt.laplacian;
    memcpy( point->descriptor, pt.descriptor, sizeof(float)*64 );
  }

  return points;
}

extern "C"
CvSeq *createOpenSURFPointSequence( CvMemStorage *storage )
{
  return cvCreateSeq( 0, sizeof(CvSeq), sizeof(OpenSURFPoint_t), storage );
}

