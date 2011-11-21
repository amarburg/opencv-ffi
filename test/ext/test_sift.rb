
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/sift'

class TestSIFT < Test::Unit::TestCase

  def setup
  end


  def test_siftDetect
    img = TestSetup::small_test_image

    params = CVFFI::SIFT::Params.new( octaves: 1 )

    # This should test the auto=conversion to greyscale
    sift = CVFFI::SIFT::detect( img, params )

    assert_not_nil sift

    puts "SIFT detected #{sift.length} points."
 end

end
