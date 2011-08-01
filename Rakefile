require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask.rb'

Rake::TestTask.new do |t|
  t.libs << 'lib/opencv-ffi' << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end

task :default => 'test'


