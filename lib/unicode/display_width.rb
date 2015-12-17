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
    end
  end
end

unless defined?(Unicode::DisplayWidth::NO_STRING_EXT) && Unicode::DisplayWidth::NO_STRING_EXT
  require_relative 'display_width/string_ext'
end

