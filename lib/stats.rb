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
end

class HourStats < GeneralStats
  attr_reader :hours

  def initialize
    super
    @hours = Hash.new
  end

  def update(commit)
    super(commit)

    hour = commit[:time].hour
    @hours[hour] ||= GeneralStats.new
    @hours[hour].update(commit)
  end
end

class DayOfWeekStats
  attr_reader :days

  def initialize
    @days = Hash.new
  end

  def update(commit)
    day = commit[:time].wday
    @days[day] ||= HourStats.new
    @days[day].update(commit)
  end
end

