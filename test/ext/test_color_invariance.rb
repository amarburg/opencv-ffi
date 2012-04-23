
require 'test/setup'

require 'opencv-ffi-wrappers'
require 'opencv-ffi-ext/color_invariance'

class TestColorInvariance < Test::Unit::TestCase

  def setup
  end

  def test_color_invariance
    img = TestSetup::test_image
    dst = img.twin

    CVFFI::ColorInvariance::cvCvtColorInvariants( img, dst, :CV_COLOR_INVARIANCE_BGR2GAUSSIAN_OPPONENT )

    TestSetup::save_image( "gaussian_opponent.jpg", dst )
  end

  def test_color_invariance
    img = TestSetup::test_image
    scx = CVFFI::Mat.new( img.image_size, :CV_32FC3 )
    scy = CVFFI::Mat.new( img.image_size, :CV_32FC3 )

    CVFFI::ColorInvariance::cvGenerateSQuasiInvariant( img, scx, scy )

    # Artificially stretch color bands for image
    min,max = [scx,scy].map { |img|
      min,max = img.minMax
      [ min.min, max.max ]
    }.transpose
    min = min.min; max = max.max

    puts "Old min %.2f max %.2f" [min,max]

    diff = 256.0/(max-min)
    offset = -min*diff

    puts "Scale by %.2f, offset by %.2f" % [diff, offset]
    scaled_scx = scx.scale_add( diff, offset )
    scaled_scy = scy.scale_add( diff, offset )

    min,max = scaled_scx.minMax
    puts "New min %.2f new max %.2f" % [min.min, max.max]

    TestSetup::save_image( "scx.jpg", scaled_scx )
    TestSetup::save_image( "scy.jpg", scaled_scy )
  end

  def test_color_invariance
    img = TestSetup::test_image
    scx = CVFFI::Mat.new( img.image_size, :CV_32FC3 )
    scy = CVFFI::Mat.new( img.image_size, :CV_32FC3 )

    CVFFI::ColorInvariance::cvGenerateSQuasiInvariant( img, scx, scy )

    params = CVFFI::GoodFeaturesParams.new
    params.max_corners = 10
    params.use_harris = true
    corners = CVFFI::ColorInvariance::quasiInvariantFeaturesToTrack( scx, scy, params )

    puts "Found #{corners.length} corners."

    display = [corners.length, 10].min
    puts "Only listing first #{display} corners" unless display == corners.length
    display.times { |i|
      puts "%d  % 4d, % 4d" % [i, corners[i].x, corners[i].y]
    }

    annotated = img.clone
    corners.each { |corner|
      CVFFI::draw_circle( annotated, corner, { color: CVFFI::CvScalar.new( x: 255, y: 255, z: 0, w: 0 ) } )
    }
    TestSetup::save_image( "invariant_corners.jpg", annotated )
  end



end
