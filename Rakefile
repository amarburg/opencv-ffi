require 'bundler/gem_tasks'
require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'yard'

task :default => 'test'

Rake::TestTask.new(:test) do |t|
#  t.libs << 'lib/opencv-ffi' << '.'
  t.libs << '.'
  t.verbose = true
  t.test_files = FileList['test/test_*.rb']
end


# Hm, let YARD take care of documention
#desc "Build the local Markdown docs to html"
#task :docs => 'html/'
#task :docs => :yard
#task :docs => FileList['README.md', 'docs/*.md'].ext('.html').pathmap("html/%f")

#directory 'html/'

#rule( ".html" => [ 
#     proc {|task_name| a = task_name.pathmap("%n.md") 
#                       if FileTest.exists? a
#                         a
#                       else
#                         task_name.pathmap("docs/%n.md") 
#                       end } ] ) do |t|
#  sh "redcarpet #{t.source} > #{t.name}"
#end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', '-', 'docs/*.md']
  t.options = [ '--output-dir','yardoc/' ]
end



