
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/sift'

class TestSIFT < Test::Unit::TestCase
  include CVFFI::Features2D

  def setup
    @img = TestSetup::small_test_image
  end

  def test_SIFTDetect
    params = SIFT::Params.new
    kps = SIFT::detect( @img, params )

    assert_not_nil kps

    puts "SIFT detected #{kps.size} keypoints"

    puts "here's the first keypoint:"
    p kps[0]

    # Test serialization/unserialization
    asYaml = kps.to_yaml
    unserialized = Keypoints.from_a( asYaml )

    assert_equal kps.length, unserialized.length
  end

  def test_SIFTDetectDescribe
    img = TestSetup::test_image
    params = SIFT::Params.new

#    sift = SIFT::detect_describe( img, params )

#    assert_not_nil sift

#    puts "SIFT detected and described #{sift.length} points."

    # Test serialization/unserialization
#    asArray = sift.to_a
#   asYaml = asArray.to_yaml
#   unserialized = Keypoints.from_a( asYaml )

#   assert_equal sift.length, unserialized.length

  end


end
