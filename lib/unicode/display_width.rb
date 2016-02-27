module Unicode
  module DisplayWidth
    VERSION = '0.3.1'.freeze
    DATA_DIR = File.join(File.dirname(__FILE__), '../../data/').freeze
    EAST_ASIAN_WIDTH_INDEX_FILENAME = (DATA_DIR + 'EastAsianWidth.index').freeze
    EAST_ASIAN_WIDTH_DATA_FILENAME  = (DATA_DIR + 'EastAsianWidth.txt').freeze
    GENERAL_CATEGORY_WIDTH_INDEX_FILENAME = (DATA_DIR + 'GeneralCategoryWidth.index').freeze

    class << self
      # A complete mapping from codepoint to (east asian) width
      def east_asian_width_table
        if defined?(@east_asian_width_table) && @east_asian_width_table
          @east_asian_width_table
        else
          @east_asian_width_table = Marshal.load(File.binread(EAST_ASIAN_WIDTH_INDEX_FILENAME))
        end
      end

      def east_asian_width(n)
        n = n.to_s.unpack('U')[0] unless n.is_a? Integer
        east_asian_width_table[n] or raise ArgumentError, 'codepoint not found'
      end

      # A table that defines values for some special characters (typically zero width)
      def general_category_width_table
        if defined?(@general_category_width_table) && @general_category_width_table
          @general_category_width_table
        else
          @general_category_width_table = Marshal.load(File.binread(GENERAL_CATEGORY_WIDTH_INDEX_FILENAME))
        end
      end

      def general_category_width(n)
        n = n.to_s.unpack('U')[0] unless n.is_a? Integer
        general_category_width_table[n]
      end

      def for(string, ambiguous = 1)
        string.unpack('U*').inject(0){ |total_width, char|
          total_width + ( general_category_width(char) ||
            case east_asian_width(char)
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
end

unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

