
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/harris_laplace'

class TestHarrisLaplace < Test::Unit::TestCase
  include CVFFI::Features2D

  def setup
    @img = TestSetup::small_test_image
    @kp_ptr = FFI::MemoryPointer.new :pointer
    @mem_storage = CVFFI::cvCreateMemStorage( 0 )
  end
  
  def test_HarrisLaplace
    params = HarrisLaplace::Params.new
    kps = HarrisLaplace::detect( @img, params )

    assert_not_nil kps

    puts "The HarrisLaplace detector found #{kps.size} keypoints"

    puts "here's the first keypoint:"
    p kps[0]

    ## Test serialization and unserialization
    asYaml = kps.to_yaml
    unserialized = Keypoints.from_a( asYaml )

    assert_equal kps.length, unserialized.length
  end

def test_HarrisAffine
    params = HarrisAffine::Params.new
    kps = HarrisAffine::detect( @img, params )

    assert_not_nil kps

    puts "The HarrisAffine detector found #{kps.size} keypoints"

    puts "here's the first keypoint:"
    p kps[0]

    asYaml = kps.to_yaml
    unserialized = EllipticKeypoints.from_a( asYaml )

    assert_equal kps.length, unserialized.length
  end


end
