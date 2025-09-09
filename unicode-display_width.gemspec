# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + "/lib/unicode/display_width/constants"

Gem::Specification.new do |s|
  s.name        = "unicode-display_width"
  s.version     = Unicode::DisplayWidth::VERSION
  s.authors     = ["Jan Lelis"]
  s.email       = ["hi@ruby.consulting"]
  s.homepage    = "https://github.com/janlelis/unicode-display_width"
  s.summary     = "Determines the monospace display width of a string in Ruby."
  s.description =  "[Unicode #{Unicode::DisplayWidth::UNICODE_VERSION}] Determines the monospace display width of a string using EastAsianWidth.txt, Unicode general category, Emoji specification, and other data."
  s.files = Dir.glob(%w[{lib,data}/**/*])
  s.extra_rdoc_files = ["README.md", "MIT-LICENSE.txt", "CHANGELOG.md"]
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.5.0'
  s.add_dependency 'unicode-emoji', '~> 4.1'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rake', '~> 13.0'

  if s.respond_to?(:metadata)
    s.metadata['changelog_uri'] = "https://github.com/janlelis/unicode-display_width/blob/main/CHANGELOG.md"
    s.metadata['source_code_uri'] = "https://github.com/janlelis/unicode-display_width"
    s.metadata['bug_tracker_uri'] = "https://github.com/janlelis/unicode-display_width/issues"
    s.metadata['rubygems_mfa_required'] = "true"
  end
end
