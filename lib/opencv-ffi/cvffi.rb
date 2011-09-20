
require 'nice-ffi'

module CVFFI
  extend NiceFFI::Library

  @pathset = NiceFFI::PathSet::DEFAULT.prepend( "#{ENV['HOME']}/usr/lib" )
end
