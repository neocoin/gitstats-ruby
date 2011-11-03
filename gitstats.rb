#!/usr/bin/env ruby

require 'pp'

class Git
  def initialize(base, ref = 'HEAD')
    @base = base
    @ref = ref
  end

  def num_authors
    sh("git shortlog -s #{@ref}").split(/\n/).count
  end

  def get_commits(&block)
    commits = Array.new if block.nil?

    commit = nil
    sh("git log --summary --numstat --pretty=format:\"HEADER: %at %ai %H %T %aN <%aE>\" #{@ref}").split(/\n/).each do |line|
      if line =~ /^HEADER:/
        parts = line.split(' ', 8)
        parts.shift

        commit = Hash.new
        commit[:time] = Time.at(parts[0].to_i)
        commit[:timezone] = parts[3]
        commit[:hash] = parts[4]
        commit[:tree] = parts[5]
        commit[:name], commit[:email] = /^(.+) <(.+)>$/.match(parts[6]).captures
        commit[:files_added] = 0
        commit[:files_deleted] = 0
        commit[:lines_added] = 0
        commit[:lines_deleted] = 0
      elsif line == ''
        if block.nil?
          commits << commit
        else
          block.call(commit)
        end
      elsif line =~ /^ /
        if line =~ /^ create/
          commit[:files_added] += 1
        elsif line =~ /^ delete/
          commit[:files_deleted] += 1
        end
      else
        added, deleted = /^(\d+)\s+(\d+)/.match(line).captures
        commit[:lines_added] += added.to_i
        commit[:lines_deleted] += deleted.to_i
      end
    end

    commits if block.nil?
  end

  def get_files(ref = nil)
    ref ||= @ref

    files = Array.new

    sh("git ls-tree -r -l #{ref}").split(/\n/).each do |line|
      parts = line.split(/\s+/, 5)
      next if parts[1] != 'blob'

      file = Hash.new
      file[:hash] = parts[2]
      file[:size] = parts[3]
      file[:name] = parts[4]

      files << file
    end

    files
  end

  private
  def sh(cmd)
    Dir.chdir(@base) do
      `#{cmd}`
    end
  end
end

class AuthorStats
  attr_reader :commits
  attr_reader :files_added
  attr_reader :files_deleted
  attr_reader :lines_added
  attr_reader :lines_deleted

  def initialize
    @commits = 0
    @files_added = 0
    @files_deleted = 0
    @lines_added = 0
    @lines_delete = 0
  end

  def update(commit)
    @commits += 1
    @files_added += commit[:files_added]
    @files_deleted += commit[:files_deleted]
    @lines_added += commit[:lines_added]
    @lines_deleted += commit[:lines_deleted]
  end
end

class StatGen
  attr_reader :num_authors
  attr_reader :num_commits
  attr_reader :commits_per_author
  attr_reader :commits_per_author_per_year
  attr_reader :commits_per_author_per_month_year
  attr_reader :commits_per_month
  attr_reader :commits_per_year
  attr_reader :commits_per_month_year
  attr_reader :lines_added_per_author
  attr_reader :lines_deleted_per_author

  def initialize
    @repos = Array.new

    @num_authors = nil
    @num_commits = nil
    @commits_per_author = nil
    @commits_per_author_per_year = nil
    @commits_per_author_per_month_year = nil
    @commits_per_month = nil
    @commits_per_year = nil
    @commits_per_month_year = nil
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
    @commits_per_author = Hash.new
    @commits_per_author_per_year = Hash.new
    @commits_per_author_per_month_year = Hash.new
    @commits_per_month = Hash.new
    @commits_per_year = Hash.new
    @commits_per_month_year = Hash.new

    @repos.each do |repo|
      @num_authors += repo.num_authors
      repo.get_commits do |commit|
        year = commit[:time].year.to_s
        month = '%02d' % commit[:time].month
        monthyear = '%04d-%02d' % [commit[:time].year, commit[:time].month]

        @commits_per_author[commit[:name]] ||= 0
        @commits_per_author_per_year[year] ||= Hash.new
        @commits_per_author_per_year[year][commit[:name]] ||= 0
        @commits_per_author_per_month_year[monthyear] ||= Hash.new
        @commits_per_author_per_month_year[monthyear][commit[:name]] ||= 0
        @commits_per_month[month] ||= 0
        @commits_per_year[year] ||= 0
        @commits_per_month_year[monthyear] ||= 0

        @num_commits += 1
        @commits_per_author[commit[:name]] += 1
        @commits_per_author_per_year[year][commit[:name]] += 1
        @commits_per_author_per_month_year[monthyear][commit[:name]] += 1
        @commits_per_month[month] += 1
        @commits_per_year[year] += 1
        @commits_per_month_year[monthyear] += 1
      end
    end
  end
end

git = Git.new('../gitolite')
pp git.get_commits
#stat = StatGen.new
#stat << '../gitolite'
#stat.calc
#pp stat.num_authors
#pp stat.num_commits
#pp stat.commits_per_author
#pp stat.commits_per_author_per_year
#pp stat.commits_per_author_per_month_year
#pp stat.commits_per_month
#pp stat.commits_per_year
#pp stat.commits_per_month_year

