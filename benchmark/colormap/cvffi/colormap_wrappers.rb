#!/usr/bin/env ruby

require "opencv-ffi-wrappers"
require "benchmark"
require "../../common/array_statistics"

include CVFFI

infile = "../../images/test_pattern_chart.jpg";
iterations = 100

img = CVFFI::Mat.new CVFFI::cvLoadImageM( infile, CVFFI::CV_LOAD_IMAGE_GRAYSCALE )

def test_function( img )
  r = img.convert( :CV_32F ) / 255
  g = 1.0 - r
  b = r * 0.2

  rgb = [b,g,r].merge( :CV_32FC3 ) * 255
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

