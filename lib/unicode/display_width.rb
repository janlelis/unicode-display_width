module Unicode
  module DisplayWidth
    VERSION = '0.3.1'.freeze
    DATA_DIRECTORY = File.join(File.dirname(__FILE__), '../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + 'EastAsianWidth.index').freeze

    class << self
      def index
        if defined?(@index) && @index
          @index
        else
          @index = Marshal.load(File.binread(INDEX_FILENAME))
        end
      end

      def of(string, ambiguous = 1)
        string.unpack('U*').inject(0){ |total_width, char|
          total_width + case width = index[char]
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
        }
      end
    end
  end
end

# Allows you to opt-out of the default string extension. Will eventually be removed,
# so you must opt-in for the core extension by requiring 'display_width/string_ext'
unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

