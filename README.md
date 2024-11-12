# Unicode::DisplayWidth [![[version]](https://badge.fury.io/rb/unicode-display_width.svg)](https://badge.fury.io/rb/unicode-display_width) [<img src="https://github.com/janlelis/unicode-display_width/workflows/Test/badge.svg" />](https://github.com/janlelis/unicode-display_width/actions?query=workflow%3ATest)

Determines the monospace display width of a string in Ruby. Useful for all kinds of terminal-based applications. Implementation based on [EastAsianWidth.txt](https://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt) and other data, 100% in Ruby. It does not rely on the OS vendor (like [wcwidth()](https://github.com/janlelis/wcswidth-ruby)) to provide an up-to-date method for measuring string width in terminals.

Unicode version: **16.0.0** (September 2024)

## Gem Version 3.0 — Improved Emoji Support

**Emoji support is now enabled by default.** See below for description and configuration possibilities.

**Unicode::DisplayWidth.of now takes keyword arguments:** { ambiguous:, emoji:, overwrite: }

## Gem Version 2.4.2 — Performance Updates

**If you use this gem, you should really upgrade to 2.4.2 or newer. It's often 100x faster, sometimes even 1000x and more!**

This is possible because the gem now detects if you use very basic (and common) characters, like ASCII characters. Furthermore, the character width lookup code has been optimized, so even when the string involves full-width or ambiguous characters, the gem is much faster now.

## Introduction to Character Widths

Guessing the correct space a character will consume on terminals is not easy. There is no single standard. Most implementations combine data from [East Asian Width](https://www.unicode.org/reports/tr11/), some [General Categories](https://en.wikipedia.org/wiki/Unicode_character_property#General_Category), and hand-picked adjustments.

### How this Library Handles Widths

Further at the top means higher precedence. Please expect changes to this algorithm with every MINOR version update (the X in 1.X.0)!

Width  | Characters                   | Comment
-------|------------------------------|--------------------------------------------------
?      | (user defined)               | Overwrites any other values
?      | Emoji                        | See "How this Library Handles Emoji Width" below
-1     | `"\b"`                       | Backspace (total width never below 0)
0      | `"\0"`, `"\x05"`, `"\a"`, `"\n"`, `"\v"`, `"\f"`, `"\r"`, `"\x0E"`, `"\x0F"` | [C0 control codes](https://en.wikipedia.org/wiki/C0_and_C1_control_codes#C0_.28ASCII_and_derivatives.29) which do not change horizontal width
1      | `"\u{00AD}"`                 | SOFT HYPHEN
2      | `"\u{2E3A}"`                 | TWO-EM DASH
3      | `"\u{2E3B}"`                 | THREE-EM DASH
0      | General Categories: Mn, Me, Zl, Zp, Cf (non-arabic)| Excludes ARABIC format characters
0      | Derived Property: Default_Ignorable_Code_Point     | Ignorable ranges
0      | `"\u{1160}".."\u{11FF}"`, `"\u{D7B0}".."\u{D7FF}"` | HANGUL JUNGSEONG
2      | East Asian Width: F, W       | Full-width characters
2      | `"\u{3400}".."\u{4DBF}"`, `"\u{4E00}".."\u{9FFF}"`, `"\u{F900}".."\u{FAFF}"`, `"\u{20000}".."\u{2FFFD}"`, `"\u{30000}".."\u{3FFFD}"` | Full-width ranges
1 or 2 | East Asian Width: A          | Ambiguous characters, user defined, default: 1
1      | All other codepoints         | -

## Install

Install the gem with:

    $ gem install unicode-display_width

Or add to your Gemfile:

    gem 'unicode-display_width'

## Usage

```ruby
require 'unicode/display_width'

Unicode::DisplayWidth.of("⚀") # => 1
Unicode::DisplayWidth.of("一") # => 2
```

### Ambiguous Characters

The second parameter defines the value returned by characters defined as ambiguous:

```ruby
Unicode::DisplayWidth.of("·", 1) # => 1
Unicode::DisplayWidth.of("·", 2) # => 2
```

### Custom Overwrites

You can overwrite how to handle specific code points by passing a hash (or even a proc) as `overwrite:` parameter:

```ruby
Unicode::DisplayWidth.of("a\tb", 1, overwrite: { "\t".ord => 10 })) # => TAB counted as 10, result is 12
```

Please note that using overwrites disables some perfomance optimizations of this gem.


### Emoji Options

The [RGI Emoji set](https://www.unicode.org/reports/tr51/#def_rgi_set) is automatically detected to adjust the width of the string. This can be disabled by passing the `emoji: false` argument:

```ruby
Unicode::DisplayWidth.of "🤾🏽‍♀️" # => 2
Unicode::DisplayWidth.of "🤾🏽‍♀️", emoji: false # => 5
```

Disabling Emoji support yields wrong results, as illustrated in the example above, but increases performance of display width calculation.

You can configure the Emoji set to match for by passing a symbol as value:

```ruby
Unicode::DisplayWidth.of "🐻‍❄", emoji: :rgi_mqe # => 3
Unicode::DisplayWidth.of "🐻‍❄", emoji: :rgi_uqe # => 2
```

#### How this Library Handles Emoji Width

There are many Emoji which get constructed by combining other Emoji in a sequence. This makes measuring the width complicated, since terminals might either display the combined Emoji or the separate parts of the Emoji individually.

Emoji Type  | Width / Comment
------------|----------------
Basic/Single Emoji character without Variation Selector | No special handling, uses mechanism from table above
Basic/Single Emoji character with VS15 (Text)           | No special handling, uses mechanism from table above
Basic/Single Emoji character with VS16 (Emoji)          | 2
Emoji Sequence                                          | 2 (only if sequence belongs to configured Emoji set)

The `emoji:` option can be used to configure which type of Emoji should be considered to have a width of 2. Other sequences are treated as non-combined Emoji, so the widths of all partial Emoji add up (e.g. width of one basic Emoji + one skin tone modifier + another basic Emoji). The following Emoji sets can be used:

Option | Descriptions
-------|-------------
`emoji: :basic`   | No width adjustments for Emoji sequences: all partial Emoji treated separately
`emoji: :rgi_fqe` | All fully-qualified RGI Emoji sequences are considered to have a width of 2
`emoji: :rgi_mqe` | All fully- and minimally-qualified RGI Emoji sequences are considered to have a width of 2
`emoji: :rgi_uqe` | All RGI Emoji sequences, regardless of qualification status are considered to have a width of 2
`emoji: :all`     | All possible/well-formed Emoji sequences are considered to have a width of 2
`emoji: true`     | Use recommended Emoji set on your platform (see below)
`emoji: false`    | No Emoji adjustments, Emoji characters with VS16 not handled

*RGI Emoji:* Emoji Recommended for General Interchange

*Qualfication:* Whether an Emoji sequence has all required VS16 codepoints

See [emoji-test.txt](https://www.unicode.org/Public/emoji/16.0/emoji-test.txt), the [unicode-emoji gem](https://github.com/janlelis/unicode-emoji) and [UTS-51](https://www.unicode.org/reports/tr51/#def_qualified_emoji_character) for more details about qualified and unqualified Emoji sequences.

### Usage with String Extension

```ruby
require 'unicode/display_width/string_ext'

"⚀".display_width # => 1
'一'.display_width # => 2
```

### Usage with Config Object

Version 2.0 introduces a keyword-argument based config object which allows you to save your configuration for later-reuse. This requires an extra line of code, but has the advantage that you'll need to define your string-width options only once:

```ruby
require 'unicode/display_width'

display_width = Unicode::DisplayWidth.new(
  # ambiguous: 1,
  overwrite: { "A".ord => 100 },
  emoji: :all,
)

display_width.of "⚀" # => 1
display_width.of "🤠‍🤢" # => 2
display_width.of "A" # => 100
```

### Usage from the Command-Line

Use this one-liner to print out display widths for strings from the command-line:

```
$ gem install unicode-display_width
$ ruby -r unicode/display_width -e 'puts Unicode::DisplayWidth.of $*[0]' -- "一"
```
Replace "一" with the actual string to measure

## Other Implementations & Discussion

- Python: https://github.com/jquast/wcwidth
- JavaScript: https://github.com/mycoboco/wcwidth.js
- C: https://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c
- C for Julia: https://github.com/JuliaLang/utf8proc/issues/2
- Golang: https://github.com/rivo/uniseg

See [unicode-x](https://github.com/janlelis/unicode-x) for more Unicode related micro libraries.

## Copyright & Info

- Copyright (c) 2011, 2015-2024 Jan Lelis, https://janlelis.com, released under the MIT
license
- Early versions based on runpaint's unicode-data interface: Copyright (c) 2009 Run Paint Run Run
- Unicode data: https://www.unicode.org/copyright.html#Exhibit1
