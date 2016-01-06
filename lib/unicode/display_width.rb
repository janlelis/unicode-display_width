# encoding: utf-8

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
          @table = Marshal.load File.respond_to?(:binread) ? File.binread(TABLE_FILE) : File.read(TABLE_FILE)
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

class String
  def display_width(ambiguous = 1)
    unpack('U*').inject(0){ |total_width, char|
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

  def display_size(*args)
    warn "Deprecation warning: Please use `String#display_width` instead of `String#display_size`"
    display_width(*args)
  end

  def display_length(*args)
    warn "Deprecation warning: Please use `String#display_width` instead of `String#display_length`"
    display_width(*args)
  end
end

# J-_-L
