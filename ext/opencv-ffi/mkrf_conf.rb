require 'mkrf'

Mkrf::Generator.new('libopencvffi', [ "*.cpp", "eigen/*.cpp", "fast/*.c" ]) { |g|
  g.include_library 'stdc++'
  g.include_library 'opencv_core', '~/usr/lib'
  g.include_header  'eigen3/signature_of_eigen3_matrix_library', '~/usr/include'
  g.cflags += "-I~/usr/include "
}

