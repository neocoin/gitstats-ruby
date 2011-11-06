module StatsHash
  def method_missing(method, *args, &block)
    @hash.send(method, *args, &block)
  end

  def each_sorted
    @hash.keys.sort.each do |key|
      yield key, @hash[key]
    end
  end
end

