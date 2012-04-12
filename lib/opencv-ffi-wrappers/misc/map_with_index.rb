
module MapWithIndex
  def map_with_index( &blk )
    a = []
    each_with_index { |k,i| a << blk.yield( k,i ) }
    a
  end
end



