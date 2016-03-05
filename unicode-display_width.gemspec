# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/lib/unicode/display_width"

Gem::Specification.new do |s|
  s.name        = "unicode-display_width"
  s.version     = Unicode::DisplayWidth::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = "mail@janlelis.de"
  s.homepage    = "http://github.com/janlelis/unicode-display_width"
  s.summary = "Support for east_asian_width string widths."
  s.description =  "This gem adds String#display_width to get the display size of a string using EastAsianWidth.txt."
  s.files = Dir.glob(%w[{lib,spec}/**/*.rb [A-Z]*.{txt,rdoc} data/unicode-width.index]) + %w{Rakefile unicode-display_width.gemspec}
  s.extra_rdoc_files = ["README.md", "MIT-LICENSE.txt", "CHANGELOG.txt"]
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.9.3', '< 3.0.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rake', '~> 10.4'
end
