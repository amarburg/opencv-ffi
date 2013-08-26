
#include <time.h>

#ifndef __BENCHMARK_H__
#define __BENCHMARK_H__

typedef struct benchmark_t {
  struct timespec res, start, stop;
} benchmark_t;


#ifdef __cplusplus
extern "C" {
#endif
  void startBenchmark( benchmark_t *benchmark );
  void stopBenchmark( benchmark_t *benchmark );
  long benchmarkDuration( benchmark_t *benchmark );
#ifdef __cplusplus
}
#endif

#endif
