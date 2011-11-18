
#include "SIFT.h"

#include <stdio.h>

typedef struct {
  int octaves;
  int intervals;
} SiftParams_t;

typedef struct {
  float xi;
  float yi;
  float mag[NUM_BINS];
  float orien[NUM_BINS];
  unsigned int num_bins;

  unsigned int scale;
} SiftKeypoint_t;

typedef struct {
  SiftKeypoint_t *kps;
  unsigned int len;
} SiftKeypoints_t;

SiftKeypoints_t *KeypointToSiftKeypoints( const vector<Keypoint> kps )
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

  SiftKeypoints_t *keypoints = new SiftKeypoints_t;
  keypoints->kps = kp_array;
  keypoints->len = kps.size();

  for( unsigned int i = 0; i < keypoints->len; i ++  ) {
    printf("Keypoint %d at %f %f\n", i, keypoints->kps[i].xi, keypoints->kps[i].yi );
  }

  return keypoints;
}

extern "C" 
SiftKeypoints_t *siftDetect( IplImage *img, SiftParams_t params )
{
  SIFT sift( img, params.octaves, params.intervals );
  sift.DetectKeypoints();

  printf("Copying keypoint structures...\n");
  return KeypointToSiftKeypoints( sift.keypoints() );
}
