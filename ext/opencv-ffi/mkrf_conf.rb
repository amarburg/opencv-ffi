require 'mkrf'

Mkrf::Generator.new('libopencvffi', [ "*.cpp", "eigen/*.cpp", "fast/*.c" ]) { |g|
  g.include_library 'stdc++'
  g.include_library 'opencv_core', "#{ENV['HOME']}/usr/lib"
  g.include_header  'eigen3/signature_of_eigen3_matrix_library', "#{ENV['HOME']}/usr/include"
  g.cflags += "-I#{ENV['HOME']}/usr/include "
}

