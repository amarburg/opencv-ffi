
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/harris_laplace'

class TestHarrisLaplace < Test::Unit::TestCase

  def setup
    @img = TestSetup::small_test_image
    @kp_ptr = FFI::MemoryPointer.new :pointer
    @mem_storage = CVFFI::cvCreateMemStorage( 0 )
  end
  
  # Tests the "wrapper" version
  def test_HarrisLaplace
    params = CVFFI::HarrisLaplace::Params.new
    kps = CVFFI::HarrisLaplace::detect( @img, params )

    assert_not_nil kps

    puts "The HarrisLaplace detector found #{kps.size} keypoints"

    puts "here's the first keypoint:"
    p kps[0]

  end

end
