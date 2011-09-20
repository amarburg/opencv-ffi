require 'mkrf'

Mkrf::Generator.new('libopencvffi', [ "*.cpp", "eigen/*.cpp", "fast/*.c" ]) { |g|
  g.include_library 'stdc++'
  g.include_library 'opencv_core'
}

