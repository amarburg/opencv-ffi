
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

  def test_normalized_color_space
    img = TestSetup::test_image
    dst = CVFFI::Mat.new( img.image_size, :CV_8UC3 )

    CVFFI::ColorInvariance::cvNormalizedColorImage( img, dst )
    TestSetup::save_image( "normalized_color_space.jpg", dst )

    channels = dst.split

    channel_names = ["B","G","R"]
    channels.each_with_index { |channel,i|
      TestSetup::save_image( "normalized_channel_#{channel_names[i]}.jpg", channel )
    }
  end

  def test_color_tensor
    img = TestSetup::test_image
    scx = CVFFI::Mat.new( img.image_size, :CV_32FC3 )
    scy = CVFFI::Mat.new( img.image_size, :CV_32FC3 )

    CVFFI::ColorInvariance::cvGenerateColorTensor( img, scx, scy )
    # Artificially stretch color bands for image
    min,max = [scx,scy].map { |img|
      min,max = img.minMax
      [ min.min, max.max ]
    }.transpose
    min = min.min; max = max.max

    diff = 256.0/(max-min)
    offset = -min*diff

    scaled_scx = scx.scale_add( diff, offset )
    scaled_scy = scy.scale_add( diff, offset )

    TestSetup::save_image( "tensor_x.jpg", scaled_scx )
    TestSetup::save_image( "tensor_y.jpg", scaled_scy )

    [true, false].each { |use_harris|
      params = CVFFI::GoodFeaturesParams.new
      params.max_corners = 10
      params.use_harris = use_harris
      corners = CVFFI::ColorInvariance::quasiInvariantFeaturesToTrack( scx, scy, params )

      puts "Found #{corners.length} corners for %s." % (use_harris ? "harris" : "Shi-Tomasi")

      display = [corners.length, 10].min
      puts "Only listing first #{display} corners" unless display == corners.length
      display.times { |i|
        puts "%d  % 4d, % 4d" % [i, corners[i].x, corners[i].y]
      }

      annotated = img.clone
      corners.each { |corner|
        CVFFI::draw_circle( annotated, corner, { color: CVFFI::CvScalar.new( x: 255, y: 255, z: 0, w: 0 ) } )
      }
      TestSetup::save_image( "color_tensor_corners_#{use_harris ? "harris" : "shitomasi"}.jpg", annotated )
    }
  end

  def test_color_invariance_detectors
    img = TestSetup::test_image
    scx = CVFFI::Mat.new( img.image_size, :CV_32FC3 )
    scy = CVFFI::Mat.new( img.image_size, :CV_32FC3 )

    CVFFI::ColorInvariance::cvGenerateSQuasiInvariant( img, scx, scy )
    #
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
 
    [true, false].each { |use_harris|
    params = CVFFI::GoodFeaturesParams.new
    params.max_corners = 10
    params.use_harris = use_harris
    corners = CVFFI::ColorInvariance::quasiInvariantFeaturesToTrack( scx, scy, params )

    puts "Found #{corners.length} corners for %s." % (use_harris ? "harris" : "Shi-Tomasi")

    display = [corners.length, 10].min
    puts "Only listing first #{display} corners" unless display == corners.length
    display.times { |i|
      puts "%d  % 4d, % 4d" % [i, corners[i].x, corners[i].y]
    }

    annotated = img.clone
    corners.each { |corner|
      CVFFI::draw_circle( annotated, corner, { color: CVFFI::CvScalar.new( x: 255, y: 255, z: 0, w: 0 ) } )
    }
    TestSetup::save_image( "invariant_corners_#{use_harris ? "harris" : "shitomasi"}.jpg", annotated )
    }
  end



end
