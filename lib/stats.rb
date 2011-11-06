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

class GeneralStats
  attr_reader :commits
  attr_reader :files_added
  attr_reader :files_deleted
  attr_reader :lines_added
  attr_reader :lines_deleted
  attr_reader :files
  attr_reader :lines
  attr_reader :first_commit
  attr_reader :last_commit

  def days
    @days.size
  end

  def initialize
    @commits = 0
    @files_added = 0
    @files_deleted = 0
    @lines_added = 0
    @lines_deleted = 0
    @files = 0
    @lines = 0
    @first_commit = nil
    @last_commit = nil
    @days = Array.new
  end

  def update(commit)
    @commits += 1
    @files_added += commit[:files_added]
    @files_deleted += commit[:files_deleted]
    @lines_added += commit[:lines_added]
    @lines_deleted += commit[:lines_deleted]
    @files = @files_added - @files_deleted
    @lines = @lines_added - @lines_deleted

    @first_commit ||= commit[:time]
    @last_commit ||= commit[:time]

    @first_commit = commit[:time] if commit[:time] < @first_commit
    @last_commit = commit[:time] if commit[:time] > @last_commit

    day = commit[:time].year.to_s + commit[:time].month.to_s + commit[:time].day.to_s
    @days << day unless @days.include? day
  end
end

class AuthorsStats < GeneralStats
  include StatsHash

  def initialize
    super
    @hash = Hash.new
  end

  def update(commit)
    super(commit)

    name = "#{commit[:name]} <#{commit[:email]}>"
    @hash[name] ||= GeneralStats.new
    @hash[name].update(commit)
  end
end

class YearStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    year = commit[:time].year
    @hash[year] ||= AuthorsStats.new
    @hash[year].update(commit)
  end
end

class MonthStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    month = commit[:time].month
    @hash[month] ||= AuthorsStats.new
    @hash[month].update(commit)
  end
end

class YearMonthStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    yearmonth = YearMonth.new(commit[:time])
    @hash[yearmonth] ||= AuthorsStats.new
    @hash[yearmonth].update(commit)
  end
end

class HourStats < GeneralStats
  include StatsHash

  def initialize
    super
    @hash = Hash.new
  end

  def update(commit)
    super(commit)

    hour = commit[:time].hour
    @hash[hour] ||= GeneralStats.new
    @hash[hour].update(commit)
  end
end

class DayOfWeekStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(commit)
    day = commit[:time].wday
    @hash[day] ||= HourStats.new
    @hash[day].update(commit)
  end
end

class FileStats
  attr_reader :count
  attr_reader :size

  def initialize
    @count = 0
    @size = 0
  end

  def update(file)
    @count += 1
    @size += file[:size]
  end
end

class FileTypeStats
  include StatsHash

  def initialize
    @hash = Hash.new
  end

  def update(file)
    type = File.extname(file[:name])
    @hash[type] ||= FileStats.new
    @hash[type].update(file)
  end
end

