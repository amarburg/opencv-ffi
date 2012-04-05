
module MapWithIndex

  def map_with_index &blk
    ary = Array.new( self.length )
    self.each_with_index { |x,i|
      ary[i] = blk.call( x, i )
    }
    ary
  end
end
