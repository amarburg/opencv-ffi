

require 'opencv-ffi-wrappers'

module AddMapWithIndex

  def map_with_index( &blk )
    a = []
    each_with_index { |k,i| a << blk.yield( k,i ) }
    a
  end
end

module CVFFI

  class Match
    attr_accessor :train, :query, :distance

    def initialize( t, q, d )
      @train = t
      @query = q
      @distance = d
    end
  end

  class MatchResults
    include Enumerable

    attr_accessor :train_set, :query_set
    attr_accessor :results

    def initialize( tset, qset )
      @train_set = tset
      @query_set = qset

      @results = []

      @by_train = []
      @by_train.extend( AddMapWithIndex )

      @by_query = []

      @mask = []
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

    def length( include_masked = false )
      if( include_masked )
      @results.length
      else
        num_unmasked
      end
    end

    alias :size :length

    def [](i)
      Match.new( @train_set[@results[i].tidx], @query_set[@results[i].qidx], @results[i].distance )
    end

    # The "public" each yields a Match to the block
    def each( include_masked = false, &blk )
      @results.each_with_index { |r,i|
        if !include_masked and !masked?(i)
          blk.yield( Match.new( @train_set[r.tidx], @query_set[r.qidx], r.distance ) )
        end
      }
    end

    # the "private" each yelds a MatchResult to the block
    def results_each_with_index( include_masked = false, &blk )
      @results.each_with_index { |r,i|
        if !include_masked and !masked?(i)
          blk.yield( r,i )
        end
      }
    end

    def results_each( include_masked = false, &blk )
      results_each_with_index { |r,i| blk.yield(r) }
    end

    def num_masked
      @mask.inject(0) { |m,s| s ? m+1 : m }
    end

    def num_unmasked
      @results.length - num_masked
    end

    def masked?( i )
      @mask[i] == true
    end

    def mask( i )
      @mask[i] = true
    end

    def unmask(i)
      @mask[i] = false
    end

    def clear_mask(i)
      @mask = []
    end

    def get_mask
      @mask
    end

    def set_mask(m)
      @mask = m
    end

    def to_Points( include_masked = false )
      pointsOne = []
      pointsTwo = []

      results_each( include_masked ) { |r|
          pointsOne << @train_set[r.tidx].to_Point
          pointsTwo << @query_set[r.qidx].to_Point
      }

      [pointsOne, pointsTwo]
    end


    def to_CvMats( include_masked = false )
      pointsOne = CVFFI::cvCreateMat( num_unmasked, 2, :CV_32F )
      pointsTwo = CVFFI::cvCreateMat( num_unmasked, 2, :CV_32F )

      results_each_with_index( include_masked ) { |r,i|
          CVFFI::cvSetReal2D( pointsOne, i, 0, @train_set[r.tidx].x )
          CVFFI::cvSetReal2D( pointsOne, i, 1, @train_set[r.tidx].y )
          CVFFI::cvSetReal2D( pointsTwo, i, 0, @query_set[r.qidx].x )
          CVFFI::cvSetReal2D( pointsTwo, i, 1, @query_set[r.qidx].y )
      }

      [pointsOne, pointsTwo]
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
