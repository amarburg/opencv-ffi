require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'yard'
require './ext/mkrf-rakehelper-monkey'

Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib/opencv-ffi' << '.'
  t.libs << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end

CLEAN.include "lib/*.so"

#Rake::ExtensionTask.new('fast')
setup_extension "opencv-ffi", "libcvffi"
setup_extension "fast", "libcvffi_fast"
setup_extension "eigen", "libcvffi_eigen"


task :default => 'test'

task :test => Mkrf::all_libs

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
  t.options = [ '--output-dir','docs/yard' ]
end

