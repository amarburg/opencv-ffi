module EachTwo
  def each_two( other )
    raise "Called each_two when lists are different lengths" unless length == other.length
    length.times { |i|
      yield at(i),other.at(i)
    }
  end
end

