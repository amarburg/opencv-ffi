

require 'test/setup'

require 'opencv-ffi'
require 'opencv-ffi-wrappers'
require 'opencv-ffi-wrappers/features2d/image_patch'

class TestImagePatch < Test::Unit::TestCase

  def setup
    @img = TestSetup::test_image

    # Generate an aritificial image, a 300x300 black field
    # With a 100-wide grey stripe down the center
    # and a white X corner-to-corner
    img = CVFFI::cvCreateImage( CVFFI::CvSize.new( [ 300,300 ] ), 8, 1 )
    CVFFI::cvSet( img, CVFFI::Scalar.new( 0,0,0,0 ).to_CvScalar, nil )
    CVFFI::cvSetImageROI( img, CVFFI::Rect.new( [100,0,100,300] ).to_CvRect )
    CVFFI::cvSet( img, CVFFI::Scalar.new( 128,0,0,0 ).to_CvScalar, nil )
    CVFFI::cvResetImageROI( img )
    CVFFI::draw_line( img, CVFFI::Point.new(0,0), CVFFI::Point.new(300,300),
                      { thickness: 2 } )
    CVFFI::draw_line( img, CVFFI::Point.new(300,0), CVFFI::Point.new(0,300),
                      { thickness: 2 } )
    @testimg = img
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
    
    patch_index = patches.draw_index_image
    TestSetup::save_image( "test_cvExtractImagePatch", patch_index )
  end

  def test_cvExtractCircularOrientedImagePatch
    kp = [ [100,100], [150,150], [199,199] ].map { |i| CVFFI::Point.new i }
    orientation = [ 5.35, 5.497, 5.35 ]

    params = CVFFI::ImagePatch::Params.new( size: 15,
                                            oriented: true,
                                            shape: :circle)

    patches = CVFFI::ImagePatch.describe( @testimg, kp, params )

    patches.each_with_index { |patch,i|
      assert_in_delta patch.angle, orientation[i],  0.1, "For orientation #{i}"
    }

    # Expect the first and last to be roughly the same
    assert_in_delta orientation.first, orientation.last, 0.1

    patch_index = patches.draw_index_image
    TestSetup::save_image( "test_cvExtractCircularOrientedImagePatch", patch_index )
  end




  def test_cvExtractOrientedImagePatch

    TestSetup::save_image( "oriented_image_patch", @testimg )

    kp = [ [100,100], [150,150], [199,199] ].map { |i| CVFFI::Point.new i }
    orientation = [ 5.35, 4.712, 5.35 ]

    params = CVFFI::ImagePatch::Params.new( size: 15,
                                            oriented: true )

    patches = CVFFI::ImagePatch.describe( @testimg, kp, params )

    patches.each_with_index { |patch,i|
      assert_in_delta patch.angle, orientation[i],  0.1, "For orientation #{i}"
    }

    # Expect the first and last to be roughly the same
    assert_in_delta orientation.first, orientation.last, 0.1

    patch_index = patches.draw_index_image
    TestSetup::save_image( "test_cvOrientedExtractImagePatch", patch_index )
  end

end
