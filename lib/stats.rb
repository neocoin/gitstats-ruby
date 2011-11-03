class GeneralStats
  attr_reader :commits
  attr_reader :files_added
  attr_reader :files_deleted
  attr_reader :lines_added
  attr_reader :lines_deleted
  attr_reader :files
  attr_reader :lines

  def initialize
    @commits = 0
    @files_added = 0
    @files_deleted = 0
    @lines_added = 0
    @lines_deleted = 0
    @files = 0
    @lines = 0
  end

  def update(commit)
    @commits += 1
    @files_added += commit[:files_added]
    @files_deleted += commit[:files_deleted]
    @lines_added += commit[:lines_added]
    @lines_deleted += commit[:lines_deleted]
    @files = @files_added - @files_deleted
    @lines = @lines_added - @lines_deleted
  end

  def [](idx)
    case idx
    when :commits
      @commits
    when :files_added
      @files_added
    when :files_deleted
      @files_deleted
    when :lines_added
      @lines_added
    when :lines_deleted
      @lines_deleted
    when :files
      @files
    when :lines
      @lines
    else
      nil
    end
  end
end

class AuthorsStats < GeneralStats
  attr_reader :authors

  def initialize
    super
    @authors = Hash.new
  end

  def update(commit)
    super(commit)

    name = "#{commit[:name]} <#{commit[:email]}>"
    @authors[name] ||= GeneralStats.new
    @authors[name].update(commit)
  end

  def [](idx)
    return super(idx) if idx.is_a? Symbol

    @authors[idx]
  end
end

class YearStats
  attr_reader :years

  def initialize
    @years = Hash.new
  end

  def update(commit)
    year = '%04d' % commit[:time].year
    @years[year] ||= AuthorsStats.new
    @years[year].update(commit)
  end

  def [](idx)
    @years[idx]
  end

  def diag(attr)
    x = Array.new
    y = Array.new

    @years.each do |year, stat|
      x << year.to_i
      y << stat[attr]
    end

    [x, y]
  end
end

class MonthStats
  attr_reader :months

  def initialize
    @months = Hash.new
  end

  def update(commit)
    month = '%02d' % commit[:time].month
    @months[month] ||= AuthorsStats.new
    @months[month].update(commit)
  end

  def [](idx)
    @months[idx]
  end

  def diag(attr)
    x = Array.new
    y = Array.new

    @months.each do |month, stat|
      x << month.to_i
      y << stat[attr]
    end

    [x, y]
  end
end

class YearMonthStats
  attr_reader :yearmonths

  def initialize
    @yearmonths = Hash.new
  end

  def update(commit)
    yearmonth = '%04d-%02d' % [commit[:time].year, commit[:time].month]
    @yearmonths[yearmonth] ||= AuthorsStats.new
    @yearmonths[yearmonth].update(commit)
  end

  def [](idx)
    @yearmonths[idx]
  end

  def diag(attr)
    x = Array.new
    y = Array.new

    @yearmonths.each do |yearmonth, stat|
      x << yearmonth
      y << stat[attr]
    end

    [x, y]
  end
end

