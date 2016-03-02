## unicode/display_width [<img src="https://travis-ci.org/janlelis/unicode-display_width.png" />](https://travis-ci.org/janlelis/unicode-display_width)

Determines the (monospace) display width of a Ruby string. Pure Ruby implementation based on [EastAsianWidth.txt](http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt) and other data. You can also use [wcswidth-ruby](https://github.com/janlelis/wcswidth-ruby) for this purpose, but it is less often updated by OS vendors, so results may differ.

## Introduction

TBD

## Install

Install the gem with:

    gem install unicode-display_width

or add to your Gemfile:

    gem 'unicode-display_width'

## Usage

TBD

- Ambiguous Characters
- Overwrite

### Usage with String Extension

Activated by default. Will be deactivated in version 2.0:

    require 'unicode/display_width/string_ext'

    "⚀".display_width #=> 1
    '一'.display_width #=> 2

Currently, you can actively opt-out from the string extension with: `require 'unicode/display_width/no_string_ext'`

## Copyright

Copyright (c) 2011, 2015-2016 Jan Lelis, http://janlelis.com, released under the MIT
license.

Early versions based on runpaint's: Copyright (c) 2009 Run Paint Run Run

Unicode data: http://www.unicode.org/copyright.html#Exhibit1
