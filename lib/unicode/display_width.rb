# encoding: utf-8
module Unicode; end
module Unicode::DisplayWidth
  VERSION = '0.2.0'
end


class << Unicode::DisplayWidth
  DATA_DIR = File.join(File.dirname(__FILE__), '../../data/')
  TABLE_FILE = DATA_DIR + 'EastAsianWidth.index'
  DATA_FILE  = DATA_DIR + 'EastAsianWidth.txt'

  # # # lookup

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


  # # # index

  def build_table
    data = File.open DATA_FILE
    data.rewind
    table = {}
    dir = File.dirname TABLE_FILE
    Dir.mkdir(dir) unless Dir.exists?(dir)
    data.each_line{ |line|
      line =~ /^(\S+?);(\S+)\s+#.*$/
      if $1 && $2
        cps, width = $1, $2
        if cps['..']
          range = Range.new *cps.split('..').map{ |cp| cp.to_i(16) }
          range.each{ |cp| table[ cp ] = width.to_sym }
        else
          table[ cps.to_i(16) ] = width.to_sym
        end
      end

    }
    File.open(TABLE_FILE, 'wb') { |f| Marshal.dump(table, f) }
  end
end


# # # core ext

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
