module Unicode
  module DisplayWidth
    VERSION = '0.3.1'.freeze
    DATA_DIR = File.join(File.dirname(__FILE__), '../../data/').freeze
    TABLE_FILE = (DATA_DIR + 'EastAsianWidth.index').freeze
    DATA_FILE  = (DATA_DIR + 'EastAsianWidth.txt').freeze

    class << self
      def table
        if defined?(@table) && @table
          @table
        else
          @table = Marshal.load(File.binread(TABLE_FILE))
        end
      end

      def codepoint(n)
        n = n.to_s.unpack('U')[0] unless n.is_a? Integer
        table[n] or raise ArgumentError, 'codepoint not found'
      end
      alias width codepoint
      alias of    codepoint

      def for(string, ambiguous = 1)
        string.unpack('U*').inject(0){ |total_width, char|
          total_width + case Unicode::DisplayWidth.codepoint(char).to_s
          when 'F', 'W'
            2
          when 'N', 'Na', 'H'
            1
          when 'A'
            ambiguous
          else
            1
          end
        }
      end
    end
  end
end

unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

