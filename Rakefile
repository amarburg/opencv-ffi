require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'mkrf/rakehelper'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib/opencv-ffi' << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end

#Rake::ExtensionTask.new('fast')
setup_extension "fast", "libfast"

task :default => 'test'



