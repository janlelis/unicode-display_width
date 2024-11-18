# frozen_string_literal: true

require "unicode/emoji"

require_relative "display_width/constants"
require_relative "display_width/index"
require_relative "display_width/emoji_support"

module Unicode
  class DisplayWidth
    INITIAL_DEPTH = 0x10000
    def self.width_in_index(codepoint, index)
      d = INITIAL_DEPTH
      w = index[codepoint / d]
      while w.instance_of? Array
        w = w[(codepoint %= d) / (d /= 16)]
      end
      w || 1
    end

    DEFAULT_AMBIGUOUS = 1
    ASCII_NON_ZERO_REGEX = /[\0\x05\a\b\n\v\f\r\x0E\x0F]/
    ASCII_NON_ZERO_STRING = "\0\x05\a\b\n\v\f\r\x0E\x0F"
    ASCII_BACKSPACE = "\b"
    AMBIGUOUS_MAP = {
      1 => :WIDTH_ONE,
      2 => :WIDTH_TWO,
    }
    FIRST_AMBIGUOUS = {
      WIDTH_ONE: 768,
      WIDTH_TWO: 161,
    }
    FIRST_4096 = {
      WIDTH_ONE: decompress_index(INDEX[:WIDTH_ONE][0][0], 1),
      WIDTH_TWO: decompress_index(INDEX[:WIDTH_TWO][0][0], 1),
    }
    VS16_TEXT_CODEPOINTS = {
      WIDTH_ONE: Unicode::Emoji::TEXT_PRESENTATION - Unicode::Emoji::EMOJI_COMPONENT,
      WIDTH_TWO: (Unicode::Emoji::TEXT_PRESENTATION - Unicode::Emoji::EMOJI_COMPONENT).reject{ |codepoint|
        width_in_index(codepoint, INDEX[:WIDTH_TWO]) == 2
      },
    }
    EMOJI_SEQUENCES_REGEX_MAPPING = {
      rgi: :REGEX_INCLUDE_MQE_UQE,
      rgi_at: :REGEX_INCLUDE_MQE_UQE,
      possible: :REGEX_WELL_FORMED,
    }
    EMOJI_NON_VS16_OPTIONS = [:all_no_vs16, :rgi_at, :none, false]
    VS16 = 0xFE0F
    REGEX_EMOJI_BASIC_OR_KEYCAP = Regexp.union(Unicode::Emoji::REGEX_BASIC, Unicode::Emoji::REGEX_EMOJI_KEYCAP)
    REGEX_EMOJI_ALL_SEQUENCES = Regexp.union(/.[\u{1F3FB}-\u{1F3FF}\u{FE0F}]?(\u{200D}.[\u{1F3FB}-\u{1F3FF}\u{FE0F}]?)+/, Unicode::Emoji::REGEX_EMOJI_KEYCAP)
    REGEX_EMOJI_NOT_POSSIBLE = /\A[#*0-9]\z/

    # Returns monospace display width of string
    def self.of(string, ambiguous = nil, overwrite = nil, old_options = {}, **options)
      unless old_options.empty?
        warn "Unicode::DisplayWidth: Please migrate to keyword arguments - #{old_options.inspect}"
        options.merge! old_options
      end

      options[:ambiguous] = ambiguous if ambiguous
      options[:ambiguous] ||= DEFAULT_AMBIGUOUS

      if options[:ambiguous] != 1 && options[:ambiguous] != 2
        raise ArgumentError, "Unicode::DisplayWidth: Ambiguous width must be 1 or 2"
      end

      if overwrite && !overwrite.empty?
        warn "Unicode::DisplayWidth: Please migrate to keyword arguments - overwrite: #{overwrite.inspect}"
        options[:overwrite] = overwrite
      end
      options[:overwrite] ||= {}

      if [nil, true, :auto].include?(options[:emoji])
        options[:emoji] = EmojiSupport.recommended
      end

      # # #

      if !options[:overwrite].empty?
        return width_frame(string, options) do |string, index_full, index_low, first_ambiguous, vs16_text_codepoints|
          width_all_features(
            string,
            index_full,
            index_low,
            first_ambiguous,
            options[:overwrite],
            EMOJI_NON_VS16_OPTIONS.include?(options[:emoji]) ? nil : vs16_text_codepoints
          )
        end
      end

      if !string.ascii_only?
        return width_frame(string, options) do |string, index_full, index_low, first_ambiguous, vs16_text_codepoints|
          if EMOJI_NON_VS16_OPTIONS.include?(options[:emoji])
            width_no_overwrite(string, index_full, index_low, first_ambiguous)
          else
            width_no_overwrite_with_vs16(string, index_full, index_low, first_ambiguous, vs16_text_codepoints)
          end
        end
      end

      width_ascii(string)
    end

    def self.width_ascii(string)
      # Optimization for ASCII-only strings without certain control symbols
      if string.match?(ASCII_NON_ZERO_REGEX)
        res = string.delete(ASCII_NON_ZERO_STRING).size - string.count(ASCII_BACKSPACE)
        return res < 0 ? 0 : res
      end

      # Pure ASCII
      string.size
    end

    def self.width_frame(string, options)
      # Retrieve Emoji width
      if options[:emoji] == false || options[:emoji] == :none
        res = 0
      else
        res, string = emoji_width(
          string,
          options[:emoji],
          options[:ambiguous],
        )
      end

      # Prepare indexes
      ambiguous_index_name = AMBIGUOUS_MAP[options[:ambiguous]]

      # Get general width
      res += yield(
        string,
        INDEX[ambiguous_index_name],
        FIRST_4096[ambiguous_index_name],
        FIRST_AMBIGUOUS[ambiguous_index_name],
        VS16_TEXT_CODEPOINTS[ambiguous_index_name]
      )

      # Return result + prevent negative lengths
      res < 0 ? 0 : res
    end

    def self.width_no_overwrite(string, index_full, index_low, first_ambiguous, _ = {})
      res = 0

      # Make sure we have UTF-8
      string = string.encode(Encoding::UTF_8) unless string.encoding.name == "utf-8"

      string.scan(/.{,80}/m){ |batch|
        if batch.ascii_only?
          res += batch.size
        else
          batch.each_codepoint{ |codepoint|
            if codepoint > 15 && codepoint < first_ambiguous
              res += 1
            elsif codepoint < 0x1001
              res += index_low[codepoint] || 1
            else
              d = INITIAL_DEPTH
              w = index_full[codepoint / d]
              while w.instance_of? Array
                w = w[(codepoint %= d) / (d /= 16)]
              end

              res += w || 1
            end
          }
        end
      }

      res
    end

    def self.width_no_overwrite_with_vs16(string, index_full, index_low, first_ambiguous, vs16_text_codepoints)
      res = 0

      # Make sure we have UTF-8
      string = string.encode(Encoding::UTF_8) unless string.encoding.name == "utf-8"

      # Track last codepoint and apply VS16 adjustment if necassary
      last_codepoint = nil

      string.scan(/.{,80}/m){ |batch|
        if batch.ascii_only?
          res += batch.size
        else
          batch.each_codepoint{ |codepoint|
            if codepoint > 15 && codepoint < first_ambiguous
              res += 1
            elsif codepoint < 0x1001
              res += index_low[codepoint] || 1
            elsif codepoint == VS16 && vs16_text_codepoints.include?(last_codepoint)
              res += 1
            else
              d = INITIAL_DEPTH
              c = codepoint
              w = index_full[c / d]
              while w.instance_of? Array
                w = w[(c %= d) / (d /= 16)]
              end

              res += w || 1
            end

            last_codepoint = codepoint
          }
        end
      }

      res
    end

    # Same as .width_no_overwrite - but with applying overwrites for each char
    def self.width_all_features(string, index_full, index_low, first_ambiguous, overwrite, vs16_text_codepoints)
      res = 0

      # Track last codepoint and apply VS16 adjustment if necassary
      last_codepoint = nil

      string.each_codepoint{ |codepoint|
        if overwrite[codepoint]
          res += overwrite[codepoint]
        elsif codepoint > 15 && codepoint < first_ambiguous
          res += 1
        elsif codepoint < 0x1001
          res += index_low[codepoint] || 1
        elsif codepoint == VS16 && vs16_text_codepoints && vs16_text_codepoints.include?(last_codepoint)
          res += 1
        else
          d = INITIAL_DEPTH
          c = codepoint
          w = index_full[c / d]
          while w.instance_of? Array
            w = w[(c %= d) / (d /= 16)]
          end

          res += w || 1
        end

        last_codepoint = codepoint
      }

      res
    end


    def self.emoji_width(string, mode = :all, ambiguous = DEFAULT_AMBIGUOUS)
      res = 0

      string = string.encode(Encoding::UTF_8) unless string.encoding.name == "utf-8"

      if emoji_set_regex = EMOJI_SEQUENCES_REGEX_MAPPING[mode]
        emoji_width_via_possible(
          string,
          Unicode::Emoji.const_get(emoji_set_regex),
          mode == :rgi_at,
          ambiguous,
        )
      elsif mode == :all_no_vs16 || mode == :all
        emoji_width_all(string)
      else
        [0, string]
      end
    end

    # Use simplistic ZWJ/modifier/kecap sequence matching
    def self.emoji_width_all(string)
      res = 0

      no_emoji_string = string.gsub(REGEX_EMOJI_ALL_SEQUENCES){
        res += 2
        ""
      }

      [res, no_emoji_string]
    end

    # Match possible Emoji first, then refine
    def self.emoji_width_via_possible(string, emoji_set_regex, strict_eaw = false, ambiguous = DEFAULT_AMBIGUOUS)
      res = 0

      # For each string possibly an emoji
      no_emoji_string = string.gsub(Unicode::Emoji::REGEX_POSSIBLE){ |emoji_candidate|
        # Skip notorious false positives
        if REGEX_EMOJI_NOT_POSSIBLE.match?(emoji_candidate)
          res += 1
          ""

        # Check if we have a combined Emoji with width 2 (or EAW an Apple Terminal)
        elsif emoji_candidate == emoji_candidate[emoji_set_regex]
          if strict_eaw
            res += self.width_in_index(emoji_candidate[0].ord, INDEX[AMBIGUOUS_MAP[ambiguous]])
          else
            res += 2
          end
          ""

        # Use other counting mechanisms
        else
          emoji_candidate
        end
      }

      [res, no_emoji_string]
    end

    def initialize(ambiguous: DEFAULT_AMBIGUOUS, overwrite: {}, emoji: true)
      @ambiguous = ambiguous
      @overwrite = overwrite
      @emoji     = emoji
    end

    def get_config(**kwargs)
      {
        ambiguous: kwargs[:ambiguous] || @ambiguous,
        overwrite: kwargs[:overwrite] || @overwrite,
        emoji:     kwargs[:emoji]     || @emoji,
      }
    end

    def of(string, **kwargs)
      self.class.of(string, **get_config(**kwargs))
    end
  end
end

