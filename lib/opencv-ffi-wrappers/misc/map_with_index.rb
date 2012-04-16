
module MapWithIndex
  def map_with_index( &blk )
    a = []
    each_with_index { |k,i| a << blk.yield( k,i ) }
    a
  end

  def map_with_index!( &blk )
    each_with_index { |k,i| self[i] = blk.yield( k,i ) }
  end
end



