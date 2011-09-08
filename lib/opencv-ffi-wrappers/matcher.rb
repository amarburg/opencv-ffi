

require 'opencv-ffi-wrappers'

module CVFFI

  class MatchResult
    attr_accessor :train_set, :query_set
    attr_accessor :train_idx, :query_idx
    attr_accessor :distance

    def initialize( tset, tidx, qset, qidx, dist )
      @train_set = tset
      @train_idx = tidx
      @query_set = qset
      @query_idx = qidx
      @distance = dist
    end

    def to_s
      "Match t=#{@train_idx} q=#{@query_idx} distance=#{@distance}"
    end
  end

  class BruteForceMatcher

    def self.euclidian_distance( a, b )


    end

    def self.bestMatch( train, query, opts = {})
      maxDistance = opts[:max_distance] || nil
      k = opts[:k] || nil

      results = []
      query.each_with_index { |q,qidx|

        this_result = []
        train.each_with_index { |t,tidx|
          distance = block_given? ? yield( t,q ) : t.distance_to(q)

          ## Non-optimized algorithms...
          if maxDistance
            if distance < maxDistance
              this_result <<  MatchResult.new( train, tidx, query, qidx, distance )
            end
          elsif k
            if this_result.length < k
              this_result << MatchResult.new( train, tidx, query, qidx, distance )
            else
              this_result.sort! { |a,b| a.distance <=> b.distance }
              if distance < this_result[0].distance
                this_result[0] = MatchResult.new( train, tidx, query, qidx, distance )
              end
            end
          else
            if this_result.length == 0 or distance < this_result[0].distance
              this_result = [ MatchResult.new( train, tidx, query, qidx, distance ) ]
            end
          end

        }
        results[qidx] = this_result
      }

      results
    end

  end
end
