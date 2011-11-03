#!/usr/bin/env ruby

require 'rubygems'
require 'haml'
require 'sass'
require 'compass'
require 'ftools'

$: << File.dirname($0)

require 'lib/git'
require 'lib/stats'
require 'lib/statgen'
require 'lib/renderer'

require 'pp'

#git = Git.new('../gitolite')
#pp git.get_commits

stat = StatGen.new
stat << '../gitolite'
stat.calc
#pp stat.num_authors
#pp stat.num_commits
#pp stat.author_stats
#pp stat.yearmonth_stats.diag(:commits)
#pp stat.commits_per_author
#pp stat.commits_per_author_per_year
#pp stat.commits_per_author_per_month_year
#pp stat.commits_per_month
#pp stat.commits_per_year
#pp stat.commits_per_month_year

renderer = Renderer.new('template', 'out')
renderer.render(stat)

