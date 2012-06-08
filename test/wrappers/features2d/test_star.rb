

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/features2d/star'

module EachTwo
  def each2(other, &blk)
    raise "Can't call each2 unless arrays are same length (#{length} != #{other.length})" unless length == other.length

    self.each_with_index { |mine,i|
      blk.call( mine, other[i] )
    }
  end
end


class TestSTAR < Test::Unit::TestCase
  include CVFFI

  def setup
    @img = TestSetup::test_image
  end


  def test_cvExtractSTAR

    params = CVFFI::STAR::Params.new
    star = CVFFI::STAR::detect( @img, params )
    assert_not_nil star

    star.mark_on_image( @img, {:radius=>5, :thickness=>-1} )
    CVFFI::cvSaveImage( TestSetup::output_filename("starWrapperPts.jpg"), @img )

    ## Test some of the functions built into STAR::Result
    puts "Star generated #{star.length} keypoints."
    p star[0]

    # Test serialization/unserialization
    as_array = star.to_a
    unserialized = STAR::Results.from_a( as_array )

    assert_equal star.length, unserialized.length

    star.extend EachTwo
    star.each2(unserialized) { |kp,uns|
      assert kp == uns, "Unserialized STAR feature #{uns} doesn't match original #{kp}"
    }

  end

end
