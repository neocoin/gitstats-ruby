#!/usr/bin/env ruby

require 'rubygems'
require 'haml'
require 'sass'
require 'compass'
require 'gnuplot'
require 'ftools'
require 'optparse'

$: << File.dirname($0)

require 'lib/yearmonth'
require 'lib/git'
require 'lib/stats'
require 'lib/statgen'
require 'lib/renderer'
require 'lib/renderer/haml'
require 'lib/renderer/sass'
require 'lib/renderer/gnuplot'


$options = {
  :out => 'out',
  :template => nil,
  :verbose => false,
  :debug => false,
  :quiet => false,
  :cache => false,
  :statcache => nil
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: gitstats.rb [options] <gitdir1:[ref1]> [<gitdir2:[ref2]> ...]'

  opts.on('-o', '--out=arg', 'output directory') do |arg|
    $options[:out] = arg
  end

  opts.on('-t', '--template=arg', 'template directory') do |arg|
    $options[:template] = arg
  end

  opts.on('-c', '--[no-]cache', 'use the cache file') do |arg|
    $options[:cache] = arg
  end

  opts.on('-s', '--statcache=arg', 'statcache file to use') do |arg|
    $options[:statcache] = arg
  end

  opts.on('-v', '--[no-]verbose', 'verbose mode') do |arg|
    $options[:verbose] = arg
  end

  opts.on('-q', '--[no-]quiet', 'quiet mode') do |arg|
    $options[:quiet] = arg
  end

  opts.on('-d', '--[no-]debug', 'print debug messages') do |arg|
    $options[:debug] = arg
  end

  opts.on_tail('-h', '--help', 'this help') do
    puts opts
    exit 0
  end
end

parser.parse!


if $options[:quiet] && $options[:verbose]
  STDERR.puts 'cannot specify --quiet and --verbose at the same time!'
  exit 1
end

$options[:statcache] = File.join($options[:out], '.statcache') if $options[:statcache].nil?
$options[:template] = File.join(File.dirname($0), 'template') if $options[:template].nil?

stat = nil
if $options[:cache]
  begin
    puts 'trying to load cache ...' unless $options[:quiet]
    stat = Marshal::load(IO::readlines($options[:statcache]).join(''))
    stat.clear_repos
  rescue
  end
end

if stat.nil?
  if ARGV.empty?
    puts parser
    exit 1
  end

  stat = StatGen.new
end

stat.verbose = $options[:verbose]
stat.debug = $options[:debug]
stat.quiet = $options[:quiet]

ARGV.each do |path|
  path, ref = path.split(':')
  ref ||= 'HEAD'
  stat << [path, ref]
end

if $options[:cache]
  unless stat.check_repostate
    puts 'cannot use cache when working on different repositories!'
    exit 1
  end
end

puts 'fetching statistics ...' unless $options[:quiet]
begin
  stat.calc
ensure
  if $options[:cache]
    puts 'writing cache ...' unless $options[:quiet]
    cache = Marshal::dump(stat)
    File.new($options[:statcache], 'w').write(cache)
  end
end

puts 'rendering ...' unless $options[:quiet]
renderer = Renderer.new($options[:template], $options[:out], $options[:verbose])
renderer.render(stat)

