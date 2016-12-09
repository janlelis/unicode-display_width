require_relative 'display_width/constants'
require_relative 'display_width/index'

module Unicode
  module DisplayWidth
    DEPTHS = [0x10000, 0x1000, 0x100, 0x10].freeze

    def self.of(string, ambiguous = 1, overwrite = {})
      res = string.unpack('U*'.freeze).inject(0){ |total_width, codepoint|
        index_or_value = INDEX
        codepoint_depth_offset = codepoint
        DEPTHS.each{ |depth|
          index_or_value         = index_or_value[codepoint_depth_offset / depth]
          codepoint_depth_offset = codepoint_depth_offset % depth
          break unless index_or_value.is_a? Array
        }
        width = index_or_value.is_a?(Array) ? index_or_value[codepoint_depth_offset] : index_or_value
        width = ambiguous if width == :A
        total_width + (overwrite[codepoint] || width || 1)
      }

      res < 0 ? 0 : res
    end
  end
end

# Allows you to opt-out of the default string extension. Will eventually be removed,
# so you must opt-in for the core extension by requiring 'display_width/string_ext'
unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

