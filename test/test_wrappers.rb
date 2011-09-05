require 'test/setup'
require 'find'

Find.find( 'test/wrappers/' ) { |f|
  require f if f.match( "[\w\/]*/test_[\w]*" )
}

class TestWrappers < Test::Unit::TestCase

end
