
require 'test/setup'
require 'benchmark'

require 'opencv-ffi'
require 'opencv-ffi-wrappers/matcher'

class TestMatchers < Test::Unit::TestCase

  def setup
    @img_one = TestSetup::load_test_image
    @img_two = TestSetup::load_second_test_image
  end

  def extract_surf(img)
    smallImg = CVFFI::cvCreateImage( CVFFI::CvSize.new( { :height => img.height/2,
                                                              :width => img.width/2 } ),
                                    img.depth, img.nChannels )
    CVFFI::cvResize( img, smallImg, :CV_INTER_LINEAR )


    params = CVFFI::CvSURFParams.new( :hessianThreshold => 5000.0,
                                      :upright => 0,
                                      :extended => 0,
                                      :nOctaves => 1,
                                      :nOctaveLayers => 4 )

    # This should test the auto=conversion to greyscale
    surf = CVFFI::SURF::Detect( smallImg, params )

    assert_not_nil surf

    surf
  end
 

  def test_matcher

    surf_one = surf_two = results = nil
    Benchmark.bm(12) do |b|

      b.report("surf one") do
        surf_one = extract_surf( @img_one )
      end

      b.report("surf two") do
        surf_two = extract_surf( @img_two )
      end
             
      puts "Image one #{surf_one.length} features"
      puts "Image two #{surf_two.length} features"


      ## Test the "best-result" matcher
      b.report("best_match") do
        results = CVFFI::BruteForceMatcher.bestMatch( surf_one, surf_two )
      end
      puts "Matches found: " + results.map { |r| r.length }.join(' ')

      ## Test the "max distance" matcher
      b.report("distance_match") do
        results = CVFFI::BruteForceMatcher.bestMatch( surf_one, surf_two, { :max_distance => 0.1 } )
      end
      puts "Matches found: " + results.map { |r| r.length }.join(' ')

      ## Test the K-nearest-neighbor matcher
      b.report("knn_match") do
        results = CVFFI::BruteForceMatcher.bestMatch( surf_one, surf_two, { :k => 5 } )
      end
      puts "Matches found: " + results.map { |r| r.length }.join(' ')
    end

  end

end
