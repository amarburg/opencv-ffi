require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'mkrf/rakehelper'

Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib/opencv-ffi' << '.'
  t.libs << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end

CLEAN.include "lib/*.so"

#Rake::ExtensionTask.new('fast')
setup_extension "fast", "libfast"
setup_extension "opencv-ffi", "libopencvffi"
setup_extension "eigen", "libeigentocv"

task :default => 'test'



