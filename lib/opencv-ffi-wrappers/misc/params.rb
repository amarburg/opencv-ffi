
require 'opencv-ffi'

module CVFFI

  class Params

    def self.defaults; @defaults ||= {}; end

    def self.param( *args )
      while args.length > 0
        default,name = [args.pop, args.pop]
        defaults[ name ] = default
      end
    end

    attr_reader :params

    def initialize( opts = {} )
      @params = {}
      self.class.defaults.each_key { |k|
        @params[k] = (opts[k] or opts[k.to_s] or self.class.defaults[k])
        define_singleton_method( k ) { @params[k] }
        instance_eval "def #{k}=(a); @params[:#{k}] = a; end"
      }
    end

    def to_hash
      @params
    end
  end

end
