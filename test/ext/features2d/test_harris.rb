
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/harris_laplace'

require 'opencv-ffi-wrappers/misc/each_two'


class TestHarrisLaplace < Test::Unit::TestCase
  include CVFFI::Features2D

  def setup
    @img = TestSetup::tiny_test_image
    @kp_ptr = FFI::MemoryPointer.new :pointer
    @mem_storage = CVFFI::cvCreateMemStorage( 0 )
  end
  
  def test_HarrisLaplace
    params = HarrisLaplace::Params.new
    kps = HarrisLaplace::detect( @img, params )

    assert_not_nil kps

    puts "The HarrisLaplace detector found #{kps.size} keypoints"

    ## Test serialization and unserialization
    asYaml = kps.to_yaml
    unserialized = Keypoints.from_a( asYaml )

    assert_equal kps.length, unserialized.length

    kps.extend EachTwo
    kps.each_two( unserialized ) { |kp,uns|
      assert_equal kp, uns

      assert kp.x > 0.0 and kp.y > 0.0
      assert kp.y < @img.height, "Image height"
      assert kp.x < @img.width, "Image width"

    }
  end

def test_HarrisAffine
    params = HarrisAffine::Params.new
    kps = HarrisAffine::detect( @img, params )

    assert_not_nil kps

    puts "The HarrisAffine detector found #{kps.size} keypoints"

    asYaml = kps.to_yaml
    unserialized = EllipticKeypoints.from_a( asYaml )

    assert_equal kps.length, unserialized.length

    kps.extend EachTwo
    kps.each_two( unserialized ) { |kp,uns|
      assert_equal kp, uns

      assert kp.centre.x > 0.0 and kp.centre.y > 0.0
      assert kp.centre.y < @img.height, "Image height"
      assert kp.centre.x < @img.width, "Image width"
    }
  end


end
