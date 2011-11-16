require '../mkrf-monkey'

Mkrf::Generator.new('libcvffi_sift', [ "*.cpp" ], { :compiler=>"g++"}) { |g|
  g.include_library 'stdc++'
  raise "Can't find 'opencv_core'" unless g.include_library 'opencv_core', 'main', "#{ENV['HOME']}/usr/lib"
}

