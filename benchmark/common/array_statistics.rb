module ArrayStatistics

  def mean( alt = Float::NAN )
    length > 0 ? sum/length : alt
  end

  def median
    if (length % 2 == 0)
      at( length/2 )
    else
      [ at( (length/2).ceil ), at( (length/2).floor ) ].mean
    end
  end

  def angular_mean
    ssum = inject(0.0) { |m,v|  m+=Math::sin v }
    csum = inject(0.0) { |m,v|  m+=Math::cos v }
    Math::atan2( ssum/length, csum/length )
  end

  def variance
    m = mean
    (reduce( 0.0 ) { |memo,s| memo += (s-m)*(s-m) }) / length
  end

  def angular_variance 
    m = angular_mean
    (reduce( 0.0 ) { |memo,s| 
      diff = s-m
      diff %= Math::TWOPI
      diff -= Math::TWOPI if diff > Math::PI
      diff += Math::TWPI if diff < -Math::PI
      memo += diff*diff }) / length
  end

  def stddev
    Math::sqrt variance
  end

  def sum
    reduce( 0.0 ) { |memo,s| memo +=s }
  end

  def rms
    Math.sqrt( reduce( 0.0 ) { |memo,s| memo += s*s } / length )
  end

  def norm_l2
    reduce(0.0) { |m,s| m += s*s }
  end

  def normalize
    s = sum
    map { |i| i.to_f / s }
  end

  def normalize!
    s = sum
    map! { |i| i.to_f / s }
  end
end

class Array
  include ArrayStatistics

  def min_with_index
    m = min
    idx = find_index(m)
    [m,idx]
  end
end


module EachTwo
  def each_two( y, &blk )
    raise "each_two each_twoeach_two doesn't makes sense unless both arrays are the same length." unless length == y.length
    each.with_index { |x,i| blk.call x,y[i] }
  end
end


