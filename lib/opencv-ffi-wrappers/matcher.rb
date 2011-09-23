

require 'opencv-ffi-wrappers'

module AddMapWithIndex

  def map_with_index( &blk )
    a = []
    each_with_index { |k,i| a << blk.yield( k,i ) }
    a
  end
end

module CVFFI

  class MatchResults

    attr_accessor :train_set, :query_set
    attr_accessor :results


    def initialize( tset, qset )
      @train_set = tset
      @query_set = qset

      @results = []

      @by_train = []
      @by_train.extend( AddMapWithIndex )

      @by_query = []
    end

    def add_result(r)
raise RuntimeError "index greater than size of training set (#{r.train_idx} > #{train_set.size})" if r.train_idx >= train_set.size
raise RuntimeError "index greater than size of query set (#{r.query_idx} > #{query_set.size})" if r.query_idx >= query_set.size
      @results << r
      (@by_train[r.train_idx] ||= Array.new) << r
      (@by_query[r.query_idx] ||= Array.new) << r
      r
    end

    def add( tidx, qidx, dist )
      add_result MatchResult.new( tidx, qidx, dist )
    end

    def to_s
      [ "Total matches: #{@results.size}" ] + 
      @by_train.map_with_index { |r,tidx|
         "Tidx #{tidx} (#{r.nil? ? 0 : r.length}): #{r.nil? ? "" : r.map {|r| sprintf "%d(%.2e)", r.query_idx, r.dist }.join(' ') }"
      }
    end

  end

  class MatchResult
    attr_accessor :train_idx, :query_idx
    attr_accessor :distance

    alias :tidx :train_idx
    alias :qidx :query_idx
    alias :dist :distance

    def initialize( t, q, d )
      @train_idx = t
      @query_idx = q
      @distance = d
    end

    def to_s
      "Match t=#{@train_idx} q=#{@query_idx} distance=#{@distance}"
    end

    def train
      @train_set[@train_idx]
    end

    def query
      @query_set[@query_idx]
    end

  end

  class BruteForceMatcher

    def self.euclidian_distance( a, b )


    end

    def self.bestMatch( train, query, opts = {})
      maxDistance = opts[:max_distance] || nil
      k = opts[:k] || nil

      results = MatchResults.new( train, query )
      query.each_with_index { |q,qidx|

        this_result = []
        train.each_with_index { |t,tidx|
          distance = block_given? ? yield( t,q ) : t.distance_to(q)

          ## Non-optimized algorithms...
          if maxDistance
            if distance < maxDistance
              this_result <<  MatchResult.new( tidx, qidx, distance )
            end
          elsif k
            if this_result.length < k
              this_result << MatchResult.new( tidx, qidx, distance )
            else
              this_result.sort! { |a,b| a.distance <=> b.distance }
              if distance < this_result[0].distance
                this_result[0] = MatchResult.new( tidx, qidx, distance )
              end
            end
          else
            if this_result.length == 0 or distance < this_result[0].distance
              this_result = [ MatchResult.new( tidx, qidx, distance ) ]
            end
          end

        }
        this_result.each { |r| results.add_result( r ) }
      }

      results
    end

  end
end
