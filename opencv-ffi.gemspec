# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "opencv-ffi/version"

Gem::Specification.new do |s|
  s.name        = "opencv-ffi"
  s.version     = CVFFI::VERSION
  s.authors     = ["Aaron Marburg"]
  s.email       = ["aaron.marburg@pg.canterbury.ac.nz"]
  s.homepage    = "http://github.com/amarburg/opencv-ffi"
  s.summary     = %q{A wrapper around OpenCV's C interface using Ruby FFI.  Very preliminary.}
  s.description = %q{A wrapper around OpenCV's C interface using Ruby FFI.}

  s.rubyforge_project = "opencv-ffi"

  s.files         = `git ls-files`.split("\n")
  s.extensions    = "ext/mkrf_conf.rb"
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = true

  s.add_dependency "ffi"
  s.add_dependency "nice-ffi"
  s.add_dependency "mkrf"
end
