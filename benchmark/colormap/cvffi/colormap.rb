#!/usr/bin/env ruby

require "opencv-ffi"
require "benchmark"
require "../../common/array_statistics"

include CVFFI

infile = "../../images/test_pattern_chart.jpg";
iterations = 100

img = CVFFI::cvLoadImageM( infile, CVFFI::CV_LOAD_IMAGE_GRAYSCALE )

def test_function( img )
  r = CVFFI::cvCreateMat( img.rows, img.cols, :CV_32F );
  g = CVFFI::cvCreateMat( img.rows, img.cols, :CV_32F );
  b = CVFFI::cvCreateMat( img.rows, img.cols, :CV_32F );

  CVFFI::cvConvertScale( img, r, 1.0/255, 0 );

  CVFFI::cvSubRS( r, CVFFI::cvScalarAll(1.0), g, nil );
  CVFFI::cvConvertScale( r, b, 0.2, 0 );

  rgb = CVFFI::cvCreateMat( img.rows, img.cols, :CV_32FC3 );
  CVFFI::cvMerge( b, g, r, nil, rgb );
  CVFFI::cvConvertScale( rgb, rgb, 255, 0 );

  #CVFFI::cvSaveImage( "/tmp/out.jpg", rgb );
  #cvSplit( rgb, b, g, r, nil);
  #CVFFI::cvSaveImage( "/tmp/b.jpg", b );
  #CVFFI::cvSaveImage( "/tmp/g.jpg", g );
  #CVFFI::cvSaveImage( "/tmp/r.jpg", r );
end

if iterations > 1
  test_function(img)
  test_function(img)
end

durations = iterations.times.map { |i|
  GC.start
  Benchmark.measure do test_function( img ) end
}

us = durations.map { |d| d.total * 1_000_000_000 }
p us
puts "Ran #{iterations} iterations with mean %.2f  stddev %2.f" % [ us.mean, us.stddev ]

