# Unicode::DisplayWidth [![[version]](https://badge.fury.io/rb/unicode-display_width.svg)](https://badge.fury.io/rb/unicode-display_width) [<img src="https://github.com/janlelis/unicode-display_width/workflows/Test/badge.svg" />](https://github.com/janlelis/unicode-display_width/actions?query=workflow%3ATest)

Determines the monospace display width of a string in Ruby, which is useful for all kinds of terminal-based applications. The implementation is based on [EastAsianWidth.txt](https://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt), the [Emoji specfication](https://www.unicode.org/reports/tr51/) and other data, 100% in Ruby. It does not rely on the OS vendor ([wcwidth()](https://github.com/janlelis/wcswidth-ruby)) to provide an up-to-date method for measuring string width in terminals.

Unicode version: **16.0.0** (September 2024)

## Gem Version 3 — Improved Emoji Support

**Emoji support is now enabled by default.** See below for description and configuration possibilities.

**Unicode::DisplayWidth.of now takes keyword arguments:** { ambiguous:, emoji:, overwrite: }

See [CHANGELOG](/CHANGELOG.md) for details.

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

### Emoji

If your terminal supports it, the gem detects Emoji and Emoji sequences and adjusts the width of the measured string. This can be disabled by passing `emoji: false` as an argument:

```ruby
Unicode::DisplayWidth.of "🤾🏽‍♀️", emoji: :all # => 2
Unicode::DisplayWidth.of "🤾🏽‍♀️", emoji: false # => 5
```

#### How this Library Handles Emoji Width

There are many Emoji which get constructed by combining other Emoji in a sequence. This makes measuring the width complicated, since terminals might either display the combined Emoji or the separate parts of the Emoji individually.

Another aspect where terminals disagree is whether Emoji characters which have a text presentation by default (width 1) should be turned into full-width (width 2) when combined with Variation Selector 16 (*U+FEOF*).

Emoji Type  | Width / Comment
------------|----------------
Basic/Single Emoji character without Variation Selector | No special handling
Basic/Single Emoji character with VS15 (Text)           | No special handling
Basic/Single Emoji character with VS16 (Emoji)          | 2 (except with `emoji: :none` or `emoji: :all_no_vs16`
Emoji Sequence                                          | 2 (only) if Emoji belongs to configured Emoji set

The `emoji:` option can be used to configure which type of Emoji should be considered to have a width of 2 and if VS16-Emoji should be widened. Other sequences are treated as non-combined Emoji, so the widths of all partial Emoji add up (e.g. width of one basic Emoji + one skin tone modifier + another basic Emoji). The following Emoji settings can be used:

Option | Description | Example Terminals
-------|-------------|------------------
`emoji: true` or `emoji: :auto`   | Automatically use recommended Emoji setting for your terminal | -
`emoji: false` or  `emoji: :none` | No Emoji adjustments, Emoji characters with VS16 not handled | Gnome Terminal, many older terminals
`emoji: :basic`   | Full-width VS16-Emoji, but no width adjustments for Emoji sequences: All partial Emoji treated separately with a width of 2 | ?
`emoji: :rgi_fqe` | Full-width VS16-Emoji, all fully-qualified RGI Emoji sequences are considered to have a width of 2 | ?
`emoji: :rgi_mqe` | Full-width VS16-Emoji, all fully- and minimally-qualified RGI Emoji sequences are considered to have a width of 2 | ?
`emoji: :rgi_uqe` | Full-width VS16-Emoji, all RGI Emoji sequences, regardless of qualification status are considered to have a width of 2 | ?
`emoji: :possible`| Full-width VS16-Emoji, all possible/well-formed Emoji sequences are considered to have a width of 2 | ?
`emoji: :all`     | Full-width VS16-Emoji, all ZWJ/modifier/keycap sequences have a width of 2, even if they are not well-formed Emoji sequences | foot, Contour, WezTerm
`emoji: :all_no_vs16` | VS16-Emoji not handled, all ZWJ/modifier/keycap sequences to have a width of 2, even if they are not well-formed Emoji sequences | -

- *RGI Emoji:* Emoji Recommended for General Interchange
- *Qualification:* Whether an Emoji sequence has all required VS16 codepoints
- *ZWJ:* Zero-width Joiner: Codepoint `U+200D`,used in many Emoji sequences

Example:

```ruby
Unicode::DisplayWidth.of "🐻‍❄", emoji: :rgi_mqe # => 3 (2 for U+1f43b, 1 for U+2744)
Unicode::DisplayWidth.of "🐻‍❄", emoji: :rgi_uqe # => 2
```

See [emoji-test.txt](https://www.unicode.org/Public/emoji/16.0/emoji-test.txt), the [unicode-emoji gem](https://github.com/janlelis/unicode-emoji) and [UTS-51](https://www.unicode.org/reports/tr51/#def_qualified_emoji_character) for more details about qualified and unqualified Emoji sequences.

#### Emoji Support in Terminals

Unfortunately, the level of Emoji support varies a lot between terminals. While some of them are able to display (almost) all Emoji sequences correctly, others fall back to displaying sequences of basic Emoji. When `emoji: true` or `emoji: :auto` is used, the gem will attempt to set the best fitting Emoji setting for you (e.g. `:rgi_uqe` on "Apple_Terminal" or `:none` on Gnome's terminal widget).

Note that Emoji display and number of terminal columns used might differs a lot. For example, it might be the case that a terminal does not understand which Emoji to display, but still manages to calculate the proper amount of terminal cells. The automatic Emoji support level per terminal only considers the latter (cursor position), not the actual Emoji image(s) displayed. Please [open an issue](https://github.com/janlelis/unicode-display_width/issues/new) if you notice your terminal application could use a better default value. Also see the [ucs-detect project], which is a great resource that compares various terminal's Unicode/Emoji capabilities.

---

To terminal implementors reading this: Although handling Emoji/ZWJ sequences as always having a width of 2 (`:all` mode described above) has some advantages, it does not lead to a particularly good developer experience. Since there is always the possibility of well-formed Emoji that are currently not supported (non-RGI / future Unicode) appearing, those sequences will take more cells. Instead of overflowing, cutting off sequences or displaying placeholder-Emoji, could it be worthwile to implement the `:rgi_uqe` option (see table above) and just give those unknown Emoji the space they need? It is painful to implement, I know, but it kind of underlines the idea that the meaning of an unknown Emoji sequence can still be conveyed (without messing up the terminal at the same time). Just a thought…

---

### Usage with String Extension

```ruby
require 'unicode/display_width/string_ext'

"⚀".display_width # => 1
'一'.display_width # => 2
```

### Usage with Config Object

You can use a config object that allows you to save your configuration for later-reuse. This requires an extra line of code, but has the advantage that you'll need to define your string-width options only once:

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
