
require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-ext/features2d/sift'

module EachTwo
  def each2(other, &blk)
    raise "Can't call each2 unless arrays are same length (#{length} != #{other.length})" unless length == other.length

     self.each_with_index { |mine,i|
       blk.call( mine, other[i] )
     }
  end
end

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
    puts "here's the second keypoint:"
    p kps[1]

    # Test serialization/unserialization
    as_array = kps.to_a
    unserialized = SIFT::Results.from_a( as_array.to_yaml )
    assert_equal kps.length, unserialized.length

    puts "Here's the first feature serialized: #{as_array.first}"
    puts "Here's the first 100 bytes as yaml: #{as_array.to_yaml[0,300]}"

    kps.extend EachTwo
    kps.each2(unserialized) { |kp,uns|
      assert kp == uns, "Unserialized SIFT feature #{uns} doesn't match original #{kp}"
    }
  end

  def test_SIFTDetectDescribe
    params = SIFT::Params.new

    kps = SIFT::detect_describe( @img, params )

    assert_not_nil kps

    puts "SIFT detected and described #{kps.size} points."

    # Test serialization/unserialization
    as_array = kps.to_a
    unserialized = SIFT::Results.from_a( as_array.to_yaml )
    assert_equal kps.length, unserialized.length

#puts "KP  descriptor: #{kps.first.descriptor.to_a.join(',')}"
#puts "UNS descriptor: #{unserialized.first.descriptor.to_a.join(',')}"
    #puts "Here's the first feature serialized: #{as_array.first}"
    #puts "Here's the first 100 bytes as yaml: #{as_array.to_yaml[0,300]}"

    kps.extend EachTwo
    kps.each2(unserialized) { |kp,uns|
      assert kp == uns, "Unserialized SIFT feature and descriptor #{uns} doesn't match original #{kp}"
    }
  end


end
