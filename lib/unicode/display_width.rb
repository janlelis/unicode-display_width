# frozen_string_literal: true

require "unicode/emoji"

require_relative "display_width/constants"
require_relative "display_width/index"

module Unicode
  class DisplayWidth
    INITIAL_DEPTH = 0x10000
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
    DEFAULT_EMOJI_OPTIONS = {
      sequences: :rgi_fqe,
      wide_text_presentation: false,
    }
    EMOJI_SEQUENCES_REGEX_MAPPING = {
      rgi_fqe: :REGEX,
      rgi_mqe: :REGEX_INCLUDE_MQE,
      rgi_uqe: :REGEX_INCLUDE_MQE_UQE,
      all: :REGEX_WELL_FORMED,
    }
    EMOJI_NOT_POSSIBLE = /\A[#*0-9]\z/

    # Returns monospace display width of string
    def self.of(string, ambiguous = 1, overwrite = {}, options = {})
      if ambiguous != 1 && ambiguous != 2
        raise ArgumentError, "Unicode::DisplayWidth: ambiguous width must be 1 or 2"
      end

      if !overwrite.empty?
        return width_frame(string, options.merge(ambiguous: ambiguous)) do |string, index_full, index_low, first_ambiguous|
          width_all_features(string, index_full, index_low, first_ambiguous, overwrite)
        end
      end

      if !string.ascii_only?
        return width_frame(string, options.merge(ambiguous: ambiguous)) do |string, index_full, index_low, first_ambiguous|
          width_no_overwrite(string, index_full, index_low, first_ambiguous)
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
      if options[:emoji] == false
        res = 0
      else
        emoji_options = ( options[:emoji] == true || !options || !options[:emoji] ) ?
          DEFAULT_EMOJI_OPTIONS :
          options[:emoji]
        res, string = emoji_width(string, **emoji_options)
      end

      # Prepare indexes
      ambiguous_index_name = AMBIGUOUS_MAP[options[:ambiguous]]

      # Get general width
      res += yield(string, INDEX[ambiguous_index_name], FIRST_4096[ambiguous_index_name], FIRST_AMBIGUOUS[ambiguous_index_name])

      # Return result + prevent negative lengths
      res < 0 ? 0 : res
    end

    def self.width_no_overwrite(string, index_full, index_low, first_ambiguous, _ = {})
      res = 0

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

    # Same as .width_no_overwrite - but with applying overwrites for each char
    def self.width_all_features(string, index_full, index_low, first_ambiguous, overwrite)
      res = 0

      string.each_codepoint{ |codepoint|
        if overwrite[codepoint]
          res += overwrite[codepoint]
        elsif codepoint > 15 && codepoint < first_ambiguous
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

      res
    end


    def self.emoji_width(string, sequences: :rgi_fqe, wide_text_presentation: false)
      res = 0

      if regex = EMOJI_SEQUENCES_REGEX_MAPPING[sequences]
        emoji_sequence_regex = Unicode::Emoji.const_get(regex)
      else # sequences == :none
        emoji_sequence_regex = /$^/
      end

      # Make sure we have UTF-8
      string = string.encode("utf-8") unless string.encoding.name == "utf-8"

      # For each string possibly an emoji
      no_emoji_string = string.gsub(Unicode::Emoji::REGEX_POSSIBLE){ |emoji_candidate|
        # Skip notorious false positives
        if EMOJI_NOT_POSSIBLE.match?(emoji_candidate)
          emoji_candidate

        # Check if we have a combined Emoji with width 2
        elsif emoji_candidate == emoji_candidate[emoji_sequence_regex]
          res += 2
          ""

        # We are dealing with a default text presentation emoji or a well-formed sequence not matching the above Emoji set
        else
          # Ensure all explicit VS16 sequences have width 2
          emoji_candidate.gsub!(Unicode::Emoji::REGEX_BASIC){ |basic_emoji|
            if basic_emoji.size == 2 # VS16 present
              res += 2
              ""
            else
              basic_emoji
            end
          }

          # Apply wide_text_presentation option if present
          if wide_text_presentation
            emoji_candidate.gsub!(Unicode::Emoji::REGEX_TEXT){ |text_emoji|
              res += 2
              ""
            }
          end

          emoji_candidate
        end
      }

      [res, no_emoji_string]
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

