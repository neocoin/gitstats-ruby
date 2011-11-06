class StatGen
  attr_accessor :verbose
  attr_accessor :debug
  attr_accessor :quiet
  attr_accessor :future
  attr_accessor :maxage
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
    @future = true
    @maxage = 0

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
    @repostate.keys.each do |name|
      return false if @repos.find { |x| x.name == name }.nil?
    end
    true
  end

  def add(name, directory, ref = 'HEAD')
    @repos << Git.new(name, directory, ref, @debug)
  end

  def <<(value)
    add(value[0], value[1], value[2])
  end

  def calc
    @repos.each do |repo|
      @repostate[repo.name] ||= {
        :authors => false,
        :last => nil
      }

      puts "  repository '#{repo.name}' ..." unless @quiet

      if !@repostate[repo.name][:authors]
        @num_authors += repo.num_authors
        @repostate[repo.name][:authors] = true
      end

      repo.get_commits(@repostate[repo.name][:last]) do |commit|
        next if !@future && (commit[:time] > Time.now)
        next if (@maxage > 0) && ((Time.now - commit[:time]) > @maxage)

        puts "    commit #{@num_commits} ..." if @verbose && ((@num_commits % 100) == 0)

        @num_commits += 1
        @general_stats.update(commit)
        @author_stats.update(commit)
        @year_stats.update(commit)
        @month_stats.update(commit)
        @yearmonth_stats.update(commit)
        @hour_stats.update(commit)
        @wday_stats.update(commit)

        @repostate[repo.name][:last] = commit[:hash]
      end
    end
  end
end

