class StatGen
  attr_accessor :verbose
  attr_accessor :debug
  attr_accessor :quiet
  attr_reader :repos
  attr_reader :num_authors
  attr_reader :num_commits
  attr_reader :general_stats
  attr_reader :author_stats
  attr_reader :year_stats
  attr_reader :month_stats
  attr_reader :yearmonth_stats
  attr_reader :hour_stats
  attr_reader :wday_stats

  def initialize
    @repos = Array.new
    @repostate = Hash.new

    @verbose = false
    @debug = false
    @quiet = false

    @num_authors = 0
    @num_commits = 0
    @general_stats = GeneralStats.new
    @author_stats = AuthorsStats.new
    @year_stats = YearStats.new
    @month_stats = MonthStats.new
    @yearmonth_stats = YearMonthStats.new
    @hour_stats = HourStats.new
    @wday_stats = DayOfWeekStats.new
  end

  def clear_repos
    @repos = Array.new
  end

  def check_repostate
    @repostate.keys.each do |base|
      return false if @repos.find { |x| x.base == base }.nil?
    end
    true
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
    @repos.each do |repo|
      @repostate[repo.base] ||= {
        :authors => false,
        :last => nil
      }

      puts "  repository '#{repo.base}' ..." unless @quiet

      if !@repostate[repo.base][:authors]
        @num_authors += repo.num_authors
        @repostate[repo.base][:authors] = true
      end

      repo.get_commits(@repostate[repo.base][:last]) do |commit|
        next if commit[:time] > Time.now
        next if (Time.now - commit[:time]) > (10 * 365 * 24 * 60 * 60)

        puts "    commit #{@num_commits} ..." if @verbose && ((@num_commits % 100) == 0)

        @num_commits += 1
        @general_stats.update(commit)
        @author_stats.update(commit)
        @year_stats.update(commit)
        @month_stats.update(commit)
        @yearmonth_stats.update(commit)
        @hour_stats.update(commit)
        @wday_stats.update(commit)

        @repostate[repo.base][:last] = commit[:hash]
      end
    end
  end
end

