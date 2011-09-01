require 'test/setup'
require 'opencv-ffi/features2d'
require 'find'

Find.find( 'test/features2d/' ) { |f|
  require f if f.match( "test/features2d/test_[\w]*" )
}

class TestFeatures2d < Test::Unit::TestCase

end
