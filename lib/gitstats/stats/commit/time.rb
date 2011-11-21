class YearCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    year = commit[:time].year
    @hash[year] ||= AuthorsCommitStats.new
    @hash[year].update(commit)
  end
end

class MonthCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    month = commit[:time].month
    @hash[month] ||= AuthorsCommitStats.new
    @hash[month].update(commit)
  end
end

class YearMonthCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    yearmonth = YearMonth.new(commit[:time])
    @hash[yearmonth] ||= AuthorsCommitStats.new
    @hash[yearmonth].update(commit)
  end
end

class DateCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    t = commit[:time]
    date = Date.civil(t.year, t.month, t.day)
    @hash[date] ||= AuthorsCommitStats.new
    @hash[date].update(commit)
  end
end

class HourCommitStats < CommitStats
  include StatsHash

  def initialize
    super
    @hash = Hash.new
  end

  def update(commit)
    super(commit)

    hour = commit[:time].hour
    @hash[hour] ||= CommitStats.new
    @hash[hour].update(commit)
  end
end

class DayOfWeekCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    day = commit[:time].wday
    @hash[day] ||= HourCommitStats.new
    @hash[day].update(commit)
  end
end

class LastWeeksCommitStats
  include StatsHash

  def initialize
    @hash = Hash.new
    @base = Time.now
  end

  def update(commit)
    return if commit[:time] > @base

    diff = ((@base - commit[:time]) / 604800).to_i
    return if diff >= 52

    @hash[diff] ||= CommitStats.new
    @hash[diff].update(commit)
  end
end

