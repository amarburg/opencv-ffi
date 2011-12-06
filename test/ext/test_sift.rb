
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/sift'

class TestSIFT < Test::Unit::TestCase

  def setup
  end


  def test_siftDetect
    #img = TestSetup::small_test_image
    img = TestSetup::test_image

    params = CVFFI::SIFT::Params.new

    sift = CVFFI::SIFT::detect( img, params )

    assert_not_nil sift

    puts "SIFT detected #{sift.length} points."
    sift.each { |s|
      puts "(%.2f %.2f), size = %.2f, angle = %.2f, response = %.2f, octave = %.2f" % [s.x, s.y, s.size, s.angle, s.response, s.octave]
    }

    # Test serialization/unserialization
    asArray = sift.to_a
    asYaml = asArray.to_yaml
    unserialized = CVFFI::SIFT::Keypoints.from_a( asYaml )

    assert_equal sift.length, unserialized.length
  end

  def test_siftDetectDescribe
    img = TestSetup::test_image
    params = CVFFI::SIFT::Params.new

    sift = CVFFI::SIFT::detect_describe( img, params )

    assert_not_nil sift

    puts "SIFT detected #{sift.length} points."
    sift.each { |s|
      puts "(%.2f %.2f), size = %.2f, angle = %.2f, response = %.2f, octave = %.2f" % [s.x, s.y, s.size, s.angle, s.response, s.octave]
    }

    # Test serialization/unserialization
    asArray = sift.to_a
    asYaml = asArray.to_yaml
    
p asYaml

    unserialized = CVFFI::SIFT::Keypoints.from_a( asYaml )

    assert_equal sift.length, unserialized.length

  end


end
