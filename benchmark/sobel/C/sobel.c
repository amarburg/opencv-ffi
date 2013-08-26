
#include <stdio.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc_c.h>
#include "../../common/benchmark.h"

const int iterations = 1000;

long test_function(CvMat *in )
{
  benchmark_t timer;
  startBenchmark( &timer );

  CvMat *out = cvCreateMat( in->rows, in->cols, CV_8UC1 );
  cvSobel( in, out, 1, 0, 3 );

  stopBenchmark( &timer );

  return benchmarkDuration( &timer );
}


int main( int argc, char **argv )
{
  const char *infile = "../../images/test_pattern_chart.jpg";
  const char *outfile = "foo.jpg";
  int i = 0;
  long durations[ iterations ];

   CvMat *in = cvLoadImageM( infile, CV_LOAD_IMAGE_GRAYSCALE );
  for( i = -2; i < iterations; i++ ) {

    if( durations >= 0 ) durations[i] = test_function( in );
  }

  float mean = 0, variance = 0;
  for( i = 0; i<iterations; i++ ) {
    mean += durations[i];

    printf( "%ld\n", durations[i] );
  }
  mean /= iterations;

  for( i = 0; i < iterations; i++ ) {
    variance += (durations[i] - mean) * (durations[i] - mean);
  }
  float stddev = sqrtf( variance );

  printf("Mean duration over %d iterations (us): %.2f  (sigma = %.2f)\n", iterations, mean, stddev);
}
