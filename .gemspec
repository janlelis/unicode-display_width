# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/unicode/display_width"

Gem::Specification.new do |s|
  s.name        = "unicode-display_width"
  s.version     = Unicode::DisplayWidth::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = "http://github.com/janlelis/unicode-display_width"
  s.summary = "Support for east_asian_width string widths."
  s.description =  "This gem adds String#display_size to get the display size of a string using EastAsianWidth.txt."
  s.required_rubygems_version = ">= 1.3.6"
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} data/EastAsianWidth.index ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt", "CHANGELOG.txt"]
  s.license = 'MIT'
  s.add_development_dependency 'rspec', '~> 3.2'
  s.add_development_dependency 'rake', '~> 10.4'
end
