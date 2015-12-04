# encoding: utf-8

module Unicode
  module DisplayWidth
    VERSION = '0.2.0'
    DATA_DIR = File.join(File.dirname(__FILE__), '../../data/').freeze
    TABLE_FILE = (DATA_DIR + 'EastAsianWidth.index').freeze
    DATA_FILE  = (DATA_DIR + 'EastAsianWidth.txt').freeze

    class << self
      def table
        if @table
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
    unpack('U*').inject(0){ |a,c|
      width = case Unicode::DisplayWidth.codepoint(c).to_s
              when *%w[F W]
                2
              when *%w[N Na H]
                1
              when *%w[A]
                ambiguous
              else
                1
              end
      a + width
    }
  end
  alias display_size   display_width
  alias display_length display_width
end

# J-_-L
