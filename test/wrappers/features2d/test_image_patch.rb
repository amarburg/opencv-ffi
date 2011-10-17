

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/features2d/image_patch'

class TestImagePatch < Test::Unit::TestCase

  def setup
    @img = TestSetup::test_image
  end


  def test_cvExtractImagePatch

    params = CVFFI::ImagePatch::Params.new( size: 9 )

    puts "Image size = #{@img.width} x #{@img.height}"
    # With a 9x9 patch, (4,4) should be OK, but (3,4) shouldn't
    # Similarly width-5 should be OK, but width-4 shouldn't
    kp = [ [100,100],
           [150,150],
           [100,100],
           [4,4],
           [3,4],
           [@img.width-5,100], 
           [@img.width-4,100] ].map { |i| CVFFI::Point.new i }
    duds = 2

    patches = CVFFI::ImagePatch::describe( @img, kp, params )
    assert_not_nil patches

    assert_equal kp.length-duds, patches.length

    # KPs 0 and 2 should be identical
    assert_equal patches[0], patches[2]
    
 end

end
