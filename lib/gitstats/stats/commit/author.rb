class AuthorsCommitStats < CommitStats
  include StatsHash

  def initialize
    super
    @hash = Hash.new
  end

  def update(commit)
    super(commit)

    author = commit[:author]
    @hash[author] ||= CommitStats.new
    @hash[author].update(commit)
  end
end

