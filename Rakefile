require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require './ext/mkrf-rakehelper-monkey'

Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib/opencv-ffi' << '.'
  t.libs << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end

CLEAN.include "lib/*.so"

#Rake::ExtensionTask.new('fast')
setup_extension "opencv-ffi", "libopencvffi"

task 'lib/libopencvffi.so' => FileList['ext/opencv-ffi/**/*.c*', 'ext/opencv-ffi/mkrf_conf.rb']

task :default => 'test'

task :test => :libopencvffi


