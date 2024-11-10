# frozen_string_literal: true

require "unicode/emoji"

require_relative "display_width/constants"
require_relative "display_width/index"

module Unicode
  class DisplayWidth
    INITIAL_DEPTH = 0x10000
    ASCII_NON_ZERO_REGEX = /[\0\x05\a\b\n\v\f\r\x0E\x0F]/
    FIRST_4096 = decompress_index(INDEX[0][0], 1)
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

    def self.of(string, ambiguous = 1, overwrite = {}, options = {})
      if !overwrite.empty?
        return width_frame(string, options) do |string|
          width_all_features(string, ambiguous, overwrite)
        end
      end

      if !string.ascii_only?
        return width_frame(string, options) do |string|
          width_no_overwrite(string, ambiguous)
        end
      end

      # Optimization for ASCII-only strings without certain control symbols
      if string.match?(ASCII_NON_ZERO_REGEX)
        res = string.gsub(ASCII_NON_ZERO_REGEX, "").size - string.count("\b")
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
        emoji_options = ( options[:emoji] == true || !options ) ?
          DEFAULT_EMOJI_OPTIONS :
          options[:emoji]
        res, string = emoji_width(string, **emoji_options)
      end

      # Get general width
      res += yield(string)

      # Return result + prevent negative lengths
      res < 0 ? 0 : res
    end

    def self.width_no_overwrite(string, ambiguous, _ = {})
      string.codepoints.sum{ |codepoint|
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
    end

    # Same as .width_no_overwrite - but with applying overwrites for each char
    def self.width_all_features(string, ambiguous, overwrite)
      string.codepoints.sum{ |codepoint|
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
    end


    def self.emoji_width(string, sequences: :rgi_fqe, wide_text_presentation: false)
      adjustments = 0

      if regex = EMOJI_SEQUENCES_REGEX_MAPPING[sequences]
        emoji_sequence_regex = Unicode::Emoji.const_get(regex)
      else # sequences == :none
        emoji_sequence_regex = /$^/
      end

      # For each string possibly an emoji
      no_emoji_string = string.encode("utf-8").gsub(Unicode::Emoji::REGEX_POSSIBLE){ |emoji_candidate|
        # Skip notorious false positives
        if EMOJI_NOT_POSSIBLE.match?(emoji_candidate)
          emoji_candidate

        # Check if we have a combined Emoji with width 2
        elsif emoji_candidate == emoji_candidate[emoji_sequence_regex]
          adjustments += 2
          ""

        # We are dealing with a default text presentation emoji or a well-formed sequence not matching the above Emoji set
        else
          # Ensure all explicit VS16 sequences have width 2
          emoji_candidate.gsub!(Unicode::Emoji::REGEX_BASIC){ |basic_emoji|
            if basic_emoji.size == 2 # VS16 present
              adjustments += 2
              ""
            else
              basic_emoji
            end
          }

          # Apply wide_text_presentation option if present
          if wide_text_presentation
            emoji_candidate.gsub!(Unicode::Emoji::REGEX_TEXT){ |text_emoji|
              adjustments += 2
              ""
            }
          end

          emoji_candidate
        end
      }

      [adjustments, no_emoji_string]
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

