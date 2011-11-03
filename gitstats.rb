#!/usr/bin/env ruby

$: << "#{File.dirname($0)}/lib"

require 'git'
require 'stats'
require 'statgen'

require 'pp'

#git = Git.new('../gitolite')
#pp git.get_commits

stat = StatGen.new
stat << '../gitolite'
stat.calc
pp stat.num_authors
pp stat.num_commits
#pp stat.author_stats
pp stat.yearmonth_stats.diag(:commits)
#pp stat.commits_per_author
#pp stat.commits_per_author_per_year
#pp stat.commits_per_author_per_month_year
#pp stat.commits_per_month
#pp stat.commits_per_year
#pp stat.commits_per_month_year

