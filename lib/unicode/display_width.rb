# encoding: utf-8
module Unicode; end
module Unicode::DisplayWidth
  VERSION = '0.1.1'
end

class << Unicode::DisplayWidth
  DATA_DIR = File.join(File.dirname(__FILE__), '../../data/')
  TABLE_FILE = DATA_DIR + 'EastAsianWidth.index'
  DATA_FILE  = DATA_DIR + 'EastAsianWidth.txt'

  # only needed for building the index
  def data
    @data ||= File.open DATA_FILE
  end

  def table
    if @table
      @table
    else
      build_table unless File.file?(TABLE_FILE)
      @table = Marshal.load File.respond_to?(:binread) ? File.binread(TABLE_FILE) : File.read(TABLE_FILE)
    end
  end

  def codepoint(n)
    n = n.to_s.unpack('U')[0] unless n.is_a? Integer
    table[n] or raise ArgumentError
  end
  alias width codepoint
  alias of    codepoint

  def build_table
    data.rewind
    table = {}
    dir = File.dirname TABLE_FILE
    Dir.mkdir(dir) unless Dir.exists?(dir)
    data.lines.each{ |line|
      line =~ /^(.*);(.*) # .*$/
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

class String
  def display_width(ambiguous = 1)
    #codepoints.inject(0){ |a,c|
    unpack('U*').inject(0){ |a,c|
      width = case Unicode::DisplayWidth.codepoint(c).to_s
              when *%w[F W]
                2
              when *%w[N Na H]
                1
              when *%w[A] # TODO
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
