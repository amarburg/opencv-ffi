
require 'mkrf/rakehelper'

alias :old_setup_extension :setup_extension

module Mkrf
  @all_libs = []

  def self.all_libs
    @all_libs
  end

  def self.all_libs=(a)
    @all_libs = a
  end
end

def rake( rakedir, args = nil )
  Dir.chdir( rakedir ) do
    if args
      sh "rake #{args}"
    else
      sh 'rake'
    end
  end
end

def setup_extension(dir, extension)

  old_setup_extension( dir, extension )

  ext_dir = "ext/#{dir}"
  ext_so = "#{ext_dir}/#{extension}.#{Config::CONFIG['DLEXT']}"

  task ext_so => FileList["#{ext_dir}/**/*.c*", "#{ext_dir}/mkrf_conf.rb"]

  Mkrf::all_libs << extension.to_sym

  namespace extension.to_sym do

    desc "Run \"rake clean\" in #{ext_dir}"
    task :clean do
      rake ext_dir, 'clean'
    end

    desc "Run \"rake clobber\" in #{ext_dir}"
    task :clobber do
      rake extd_dir, 'clobber'
    end
  end

end
