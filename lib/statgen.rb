class StatGen
  attr_reader :num_authors
  attr_reader :num_commits
  attr_reader :author_stats
  attr_reader :year_stats
  attr_reader :month_stats
  attr_reader :yearmonth_stats

  def initialize
    @repos = Array.new

    @num_authors = nil
    @num_commits = nil
    @author_stats = nil
    @year_stats = nil
    @month_stats = nil
    @yearmonth_stats = nil
  end

  def add(directory, ref = 'HEAD')
    @repos << Git.new(directory, ref)
  end

  def <<(directory)
    add(directory)
  end

  def calc
    @num_authors = 0
    @num_commits = 0
    @author_stats = AuthorsStats.new
    @year_stats = YearStats.new
    @month_stats = MonthStats.new
    @yearmonth_stats = YearMonthStats.new

    @repos.each do |repo|
      @num_authors += repo.num_authors
      repo.get_commits do |commit|
        @num_commits += 1
        @author_stats.update(commit)
        @year_stats.update(commit)
        @month_stats.update(commit)
        @yearmonth_stats.update(commit)
      end
    end
  end
end

