# frozen_string_literal: true

require_relative "display_width/constants"
require_relative "display_width/index"

module Unicode
  class DisplayWidth
    INITIAL_DEPTH = 0x10000
    ASCII_NON_ZERO_REGEX = /[\0\x05\a\b\n\v\f\r\x0E\x0F]/
    FIRST_4096 = decompress_index(INDEX[0][0], 1)

    def self.of(string, ambiguous = 1, overwrite = {}, options = {})
      # Optimization for ASCII-only strings without certain control symbols
      if overwrite.empty? && string.ascii_only?
        if string.match?(ASCII_NON_ZERO_REGEX)
          res = string.gsub(ASCII_NON_ZERO_REGEX, "").size - string.count("\b")
          return res < 0 ? 0 : res
        else
          return string.size
        end
      end

      # Sum of all chars widths
      res = string.codepoints.sum{ |codepoint|
        next overwrite[codepoint] if overwrite[codepoint]

        if codepoint > 15 && codepoint < 161 # very common
          next 1
        elsif codepoint < 0x1001
          width = FIRST_4096[codepoint]
        else
          width = INDEX
          depth = INITIAL_DEPTH
          while (width = width[codepoint / depth]).instance_of? Array
            codepoint %= depth
            depth /= 16
          end
        end

        width == :A ? ambiguous : (width || 1)
      }

      # Substract emoji error
      res -= emoji_extra_width_of(string, ambiguous, overwrite) if options[:emoji]

      # Return result + prevent negative lengths
      res < 0 ? 0 : res
    end

    def self.emoji_extra_width_of(string, ambiguous = 1, overwrite = {}, _ = {})
      require "unicode/emoji"

      extra_width = 0
      modifier_regex = /[#{ Unicode::Emoji::EMOJI_MODIFIERS.pack("U*") }]/
      zwj_regex = /(?<=#{ [Unicode::Emoji::ZWJ].pack("U") })./

      string.scan(Unicode::Emoji::REGEX){ |emoji|
        extra_width += 2 * emoji.scan(modifier_regex).size

        emoji.scan(zwj_regex){ |zwj_succ|
          extra_width += self.of(zwj_succ, ambiguous, overwrite)
        }
      }

      extra_width
    end

    def initialize(ambiguous: 1, overwrite: {}, emoji: false)
      @ambiguous = ambiguous
      @overwrite = overwrite
      @emoji     = emoji
    end

    def get_config(**kwargs)
      [
        kwargs[:ambiguous] || @ambiguous,
        kwargs[:overwrite] || @overwrite,
        { emoji: kwargs[:emoji] || @emoji },
      ]
    end

    def of(string, **kwargs)
      self.class.of(string, *get_config(**kwargs))
    end
  end
end

