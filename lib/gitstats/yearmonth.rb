class YearMonth
  include Comparable

  attr_reader :year
  attr_reader :month

  def initialize(a, b = nil)
    if a.is_a? Time
      @year = a.year
      @month = a.month
    elsif b.nil?
      @year = (a / 100).to_i
      @month = a % 100
    else
      @year = a.to_i
      @month = b.to_i
    end
  end

  def <=>(b)
    to_i <=> b.to_i
  end

  def to_i
    @year * 12 + @month - 1
  end

  def to_s
    '%04d-%02d' % [@year, @month]
  end

  def eql?(b)
    to_i == b.to_i
  end

  def hash
    to_i
  end
end
