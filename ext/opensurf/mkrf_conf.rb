require '../mkrf-monkey'

Mkrf::Generator.new('libcvffi_opensurf', [ "*.cpp"]) { |g|
  g.include_library 'stdc++'
  raise "Can't find 'opencv_core'" unless g.include_library 'opencv_core', 'main', "#{ENV['HOME']}/usr/lib"
  raise "Can't find 'opencv_imgproc'" unless g.include_library 'opencv_imgproc', 'main', "#{ENV['HOME']}/usr/lib"
  g.cflags += "-I#{ENV['HOME']}/usr/include "
}


