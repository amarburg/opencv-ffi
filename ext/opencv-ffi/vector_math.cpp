
#include <stdint.h>

typedef struct {
  unsigned int len;
  uint8_t *data;
} uint8_array_t;

typedef struct {
  float d[64];
} float64_t;

typedef struct {
  float d[128];
} float128_t;

extern "C"
float L2distance_32f( const float64_t *a, const float64_t *b, int len )
{
  // Start with brute force algorithm
  float distance = 0.0;
  for( int i = 0; i < len; i++ ) {
    distance += (a->d[i] - b->d[i])*(a->d[i] - b->d[i]);
  }
  return distance;
}

extern "C"
float L2distance_8u( const uint8_array_t a, const uint8_array_t b )
{
  if( a.len != b.len ) { return -1.0; }

  float distance = 0.0;
  for( unsigned int i = 0; i < a.len; i++ ) {
    distance += (a.data[i] - b.data[i])*(a.data[i]-b.data[i]);
  }

  return distance;
}
