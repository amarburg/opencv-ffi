
require 'test/setup'
require 'opencv-ffi/calib3d'
require 'find'

Find.find( 'test/calib3d/' ) { |f|
  require f if f.match( "test/calib3d/test_[\w]*" )
}

class TestCalib3d < Test::Unit::TestCase

  def test_cvFundamentalMatrix
  end
end
