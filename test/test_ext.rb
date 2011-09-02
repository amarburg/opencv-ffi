require 'test/setup'
require 'find'

Find.find( 'test/ext/' ) { |f|
  require f if f.match( "test/ext/test_[\w]*" )
}

class TestExt < Test::Unit::TestCase

end
