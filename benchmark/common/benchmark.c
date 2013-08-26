

#include <stdlib.h>
#include <time.h>

#include "benchmark.h"


#define CLOCK (CLOCK_PROCESS_CPUTIME_ID)
//#define CLOCK (CLOCK_THREAD_CPUTIME_ID)

void startBenchmark( benchmark_t *benchmark )
{
  clock_getres( CLOCK, &(benchmark->res) );
  clock_gettime( CLOCK, &(benchmark->start) );
}

void stopBenchmark( benchmark_t *benchmark )
{
  clock_gettime( CLOCK, &(benchmark->stop) );
}

#define NSEC_PER_SEC (1000000000L)
long benchmarkDuration( benchmark_t *benchmark )
{
  int secs = (benchmark->stop.tv_sec - benchmark->start.tv_sec);
  long nsecs = (benchmark->stop.tv_nsec - benchmark->start.tv_nsec);

  if( nsecs < 0 ) {
    nsecs += NSEC_PER_SEC;
    --secs;
  }

  return (secs*NSEC_PER_SEC + nsecs);
}
