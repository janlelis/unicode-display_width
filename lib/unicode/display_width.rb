require_relative 'display_width/constants'

module Unicode
  module DisplayWidth
    def self.of(string, ambiguous = 1, overwrite = {})
      require_relative 'display_width/index' unless defined? ::Unicode::DisplayWidth::INDEX

      string.unpack('U*').inject(0){ |total_width, codepoint|
        total_width + (
          overwrite[codepoint] || case width = INDEX[codepoint]
                                  when Integer
                                    width
                                  when :F, :W
                                    2
                                  when :N, :Na, :H
                                    1
                                  when :A
                                    ambiguous
                                  else
                                    1
                                  end
        )
      }
    end
  end
end

# Allows you to opt-out of the default string extension. Will eventually be removed,
# so you must opt-in for the core extension by requiring 'display_width/string_ext'
unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

