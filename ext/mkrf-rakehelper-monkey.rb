
require 'mkrf/rakehelper'

alias :old_setup_extension :setup_extension


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

  ext = "ext/#{dir}"

  namespace extension.to_sym do

    desc "Run \"rake clean\" in #{ext}"
    task :clean do
      rake ext, 'clean'
    end

    desc "Run \"rake clobber\" in #{ext}"
    task :clobber do
      rake ext, 'clobber'
    end
  end

end
