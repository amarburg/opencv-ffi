
require 'opencv-ffi'

module CVFFI

  class Params

    def self.defaults; @defaults ||= {}; end
    def defaults;      self.class.defaults; end

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
        # This enables a copy constructor
        opts = opts.to_hash if opts.respond_to? :to_hash   

        # This is somewhat complicated because opts can be boolean, so the
        # original i"opts[k] or ... " formulation resulted in params set to
        # false being ignored
        @params[k] = if !opts[k].nil?
                       opts[k]
                     elsif !opts[k.to_s].nil?
                       opts[k.to_s] 
                     else 
                       self.class.defaults[k]
                     end

        define_singleton_method( k ) { @params[k] }
        instance_eval "def #{k}=(a); @params[:#{k}] = a; end"
      }
    end

    def to_hash
      @params
    end
  end

end
