
#include "SIFT.h"

#include <stdio.h>

typedef struct {
  int octaves;
  int intervals;
} SiftParams_t;

typedef struct {
  f/loat xi;
  float yi;
  float mag[NUM_BINS];
  float orien[NUM_BINS];
  unsigned int num_bins;

  unsigned int scale;
} SiftKeypoint_t;

typedef struct {
  float xi, yi;
  float fv[FVSIZE];
  unsigned int fv_size;
} SiftDescriptor_t;

typedef struct {
  SiftKeypoint_t *kps;
  SiftDescriptor_t *descs;
  unsigned int len;
} SiftResults_t;


SiftResults_t *buildSiftResults( const vector<Keypoint> kps, const vector<Descriptor> descs )
{
  printf("Creating array for %d keypoints.\n", kps.size() );
  SiftKeypoint_t *kp_array = new SiftKeypoint_t[ kps.size() ];

  unsigned int idx = 0;
  for( vector<Keypoint>::const_iterator itr = kps.begin(); itr != kps.end(); itr++ ) {
    kp_array[idx].xi = (*itr).xi;
    kp_array[idx].yi = (*itr).yi;
    kp_array[idx].scale = (*itr).scale;

    assert( (*itr).mag.size() == (*itr).orien.size() );

    kp_array[idx].num_bins = (*itr).mag.size();
    for( unsigned int j = 0; j < (*itr).mag.size(); j++ ) {
      kp_array[idx].mag[j]   = (*itr).mag[j];
      kp_array[idx].orien[j] = (*itr).orien[j];
    }

    idx++;
  }

  printf("Creating array for %d descriptors.\n", descs.size() );
  SiftDescriptor_t *desc_array = new SiftDescriptor_t[ descs.size() ];
  idx = 0;
  for( vector<Descriptor>::const_iterator itr = descs.begin(); itr != descs.end(); itr++ ) {
    desc_array[idx].xi = (*itr).xi;
    desc_array[idx].yi = (*itr).yi;

    desc_array[idx].fv_size = FVSIZE;
    for( unsigned int i = 0; i < FVSIZE; i++ ) {
      desc_array[idx].fv[i] = (*itr).fv[i];
    }
    ++idx;
  }

  SiftResults_t *results= new SiftResults_t;
  results->kps = kp_array;
  results->descs = desc_array;
  results->len = kps.size();

  return results;
}

extern "C" 
SiftResults_t *siftDetectDescribe( IplImage *img, SiftParams_t params )
{
  SIFT sift( img, params.octaves, params.intervals );
  sift.DoSift();

  return buildSiftResults( sift.keypoints(), sift.descriptors() );
}
