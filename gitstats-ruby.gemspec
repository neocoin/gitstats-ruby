# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'gitstats-ruby'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Christoph Plank']
  s.email       = ['chrisistuff@gmail.com']
  s.homepage    = 'http://rubygems.org/gems/gitstats-ruby'
  s.summary     = %q{Generates statistics of git repositories}
  s.description = %q{Generates statistics of git repositories}
  s.has_rdoc    = false

  s.add_dependency 'haml'
  s.add_dependency 'sass'
  s.add_dependency 'compass'
  s.add_dependency 'gnuplot'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
