
#include <stdio.h>
#include <opencv2/highgui/highgui_c.h>
#include <opencv2/imgproc/imgproc_c.h>
#include "../../common/benchmark.h"

const int iterations = 100;

long test_function(CvMat *in )
{
  benchmark_t timer;
  startBenchmark( &timer );

  CvMat *r = cvCreateMat( in->rows, in->cols, CV_32FC1 );
  CvMat *g = cvCreateMat( in->rows, in->cols, CV_32FC1 );
  CvMat *b = cvCreateMat( in->rows, in->cols, CV_32FC1 );

  cvConvertScale( in, r, 1./255, 0 );
  //cvCopy( r, g, NULL );
  //cvCopy( r, b, NULL );

  cvSubRS( r, cvScalarAll(1.0), g, NULL );
  cvConvertScale( r, b, 0.2, 0 );

  CvMat *rgb = cvCreateMat( in->rows, in->cols, CV_32FC3 );
  cvMerge( b, g, r, NULL, rgb );
  cvConvertScale( rgb, rgb, 255, 0 );

  stopBenchmark( &timer );

  cvSaveImage( "/tmp/out.jpg", rgb, 0 );
  cvSplit( rgb, b, g, r, NULL );
  cvSaveImage( "/tmp/b.jpg", b, 0 );
  cvSaveImage( "/tmp/g.jpg", g, 0 );
  cvSaveImage( "/tmp/r.jpg", r, 0 );

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

  return 0;
}
