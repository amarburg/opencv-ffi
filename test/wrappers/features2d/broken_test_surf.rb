

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/features2d/surf'

class TestSURF < Test::Unit::TestCase
  include CVFFI

  def setup
    @img = TestSetup::small_test_image
  end


  def test_SURFdetect

    params = SURF::Params.new
    surf = SURF::detect( @img, params )

    assert_not_nil surf

    #surf.mark_on_image( @img, {:radius=>5, :thickness=>-1} )
    #CVFFI::cvSaveImage( TestSetup::output_filename("surfWrapperPts.jpg"), @img )

    ## Test some of the functions built into SURF::Result
    p surf.first

    puts surf.first.distance_to( surf[1] )
    puts surf[1].distance_to( surf[2] )

    as_array = surf.to_a
    p as_array.first

    # Test serialization/unserialization
    as_array = surf.to_a
    unserialized = SURF::Results.from_a( as_array )

    assert_equal surf.length, unserialized.length

    surf.extend EachTwo
    surf.each2(unserialized) { |kp,uns|
      assert kp == uns, "Unserialized Surf feature #{uns} doesn't match original #{kp}"
    }

 end

end
