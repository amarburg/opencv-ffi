
require 'opencv-ffi'

module CVFFI

  class Params

    def self.defaults; @defaults ||= {}; end

    def self.param( *args )
      while args.length > 0
        default,name = [args.pop, args.pop]
        puts "processing #{name} = #{default}"
        defaults[ name ] = default
      end
    end

    attr_reader :params

    def initialize( opts = {} )
      @params = {}
      self.class.defaults.each_key { |k|
        @params[k] = (opts[k] or opts[k.to_s] or self.class.defaults[k])
        define_singleton_method( k ) { @params[k] }
      }
    end

    def to_hash
      @params
    end
  end


  class GoodFeaturesParams <  Params

    param :max_corners, 1000,
      :quality_level, 0.5,
      :min_distance, 5,
      :block_size, 3,
      :use_harris, false,
      :k, 0.04,
      :mask, nil

  end


  def self.goodFeaturesToTrack( image, params = GoodFeaturesParams.new )

    # TODO, technically, cvGoodFeaturesToTrack can also take 32FC1 data as well,
    # doesn't necessarily need to be cast to 8UC1 greyscale
    img = image.to_IplImage.ensure_greyscale
    eig_image = img.twin( :IPL_DEPTH_32F )
    temp_image = eig_image.twin

    CVFFI::cvGoodFeaturesToTrack( img, eig_image, temp_image, params.max_corners, 
                                 params.quality_level, params.min_distance, params.mask,
                                 params.block_size, params.use_harris, params.k )
  end



end
