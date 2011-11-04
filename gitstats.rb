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
  :debug => false
}

parser = OptionParser.new do |opts|
  opts.banner = 'Usage: gitstats.rb [options] <gitdir1:[ref1]> [<gitdir2:[ref2]> ...]'

  opts.on('-o', '--out=arg', 'output directory') do |arg|
    $options[:out] = arg
  end

  opts.on('-t', '--template=arg', 'template directory') do |arg|
    $options[:template] = arg
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

if ARGV.empty?
  puts parser
  exit 1
end

stat = StatGen.new($options[:debug])

ARGV.each do |path|
  path, ref = path.split(':')
  ref ||= 'HEAD'
  stat << [path, ref]
end
stat.calc

renderer = Renderer.new($options[:template], $options[:out])
renderer.render(stat)

