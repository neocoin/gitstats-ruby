#!/usr/bin/env ruby

require 'rubygems'
require 'haml'
require 'sass'
require 'compass'
require 'ftools'
require 'optparse'

$: << File.dirname($0)

require 'lib/git'
require 'lib/stats'
require 'lib/statgen'
require 'lib/renderer'

$options = {
  :out => 'out',
  :template => 'template',
  :verbose => false,
  :debug => false,
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

  opts.on('-d', '--[no-]debug', 'print debug messages') do |arg|
    $options[:debug] = arg
  end

  opts.on_tail('-h', '--help', 'this help') do
    puts opts
    exit 0
  end
end

parser.parse!

if $options[:statcache].nil?
  $options[:statcache] = File.join($options[:out], '.statcache')
end

stat = nil
if $options[:cache]
  begin
    puts 'trying to load cache ...'
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

stat.debug = $options[:debug]

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

begin
  stat.calc
ensure
  if $options[:cache]
    puts "writing cache ..."
    cache = Marshal::dump(stat)
    File.new($options[:statcache], 'w').write(cache)
  end
end

renderer = Renderer.new($options[:template], $options[:out])
renderer.render(stat)

