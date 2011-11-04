class StatGen
  attr_reader :num_authors
  attr_reader :num_commits
  attr_reader :author_stats
  attr_reader :year_stats
  attr_reader :month_stats
  attr_reader :yearmonth_stats
  attr_reader :hour_stats
  attr_reader :wday_stats

  def initialize(debug = false)
    @repos = Array.new

    @debug = debug

    @num_authors = nil
    @num_commits = nil
    @author_stats = nil
    @year_stats = nil
    @month_stats = nil
    @yearmonth_stats = nil
    @hour_stats = nil
    @wday_stats = nil
  end

  def add(directory, ref = 'HEAD')
    @repos << Git.new(directory, ref, @debug)
  end

  def <<(value)
    if value.is_a?(Array)
      add(value[0], value[1])
    else
      add(value)
    end
  end

  def calc
    @num_authors = 0
    @num_commits = 0
    @author_stats = AuthorsStats.new
    @year_stats = YearStats.new
    @month_stats = MonthStats.new
    @yearmonth_stats = YearMonthStats.new
    @hour_stats = HourStats.new
    @wday_stats = DayOfWeekStats.new

    @repos.each do |repo|
      puts "repository #{repo.base} ..."
      @num_authors += repo.num_authors
      repo.get_commits do |commit|
        next if commit[:time] > Time.now
        next if (Time.now - commit[:time]) > (10 * 365 * 24 * 60 * 60)
        puts "  commit #{@num_commits} ..." if (@num_commits % 100) == 0
        @num_commits += 1
        @author_stats.update(commit)
        @year_stats.update(commit)
        @month_stats.update(commit)
        @yearmonth_stats.update(commit)
        @hour_stats.update(commit)
        @wday_stats.update(commit)
      end
    end
  end
end

