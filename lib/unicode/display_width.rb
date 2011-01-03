# encoding: utf-8
module Unicode; end

module Unicode::DisplayWidth
  VERSION = '0.1.0'

  DATA_DIR = File.join(File.dirname(__FILE__), '../../data/')
  FIELDS = [:codepoint, :width, :name]
  INDEX_FILE = DATA_DIR + 'EastAsianWidth.index'
  DATA_FILE  = DATA_DIR + 'EastAsianWidth.txt'

  def self.data
    @@data ||= File.open DATA_FILE
  end

  def self.offsets
    @@offsets ||= Marshal.load File.respond_to?(:binread) ? File.binread(INDEX_FILE) : File.read(INDEX_FILE)
  end

  class Codepoint < Struct.new(*FIELDS)
    def initialize(*args)
      super
      self.codepoint = self.codepoint.to_i(16) if self.codepoint && self.codepoint !~ /\.\./
                                                  # TODO cleaner    # FIXME ranges
    end

    def self.from_line(line)
      line =~ /(.*);(.*) # (.*)$/
        raise 'BUG' unless line
      new $1,$2,$3
    end
  end

  def self.line(n)
    data.rewind
    offset = offsets[n] or raise ArgumentError
    data.seek offset
    data.readline.chomp
  end

  def self.codepoint(n)
    Codepoint.from_line line(n)
  end

  def self.valid_index?
    !!offsets rescue false
  end

  def self.build_index
    data.rewind
    offsets = {}
    dir = File.dirname INDEX_FILE
    Dir.mkdir(dir) unless Dir.exists?(dir)
    data.lines.map do |line|
      offsets[Codepoint.from_line(line).codepoint] = data.pos - line.size
    end
    File.open(INDEX_FILE, 'wb') { |f| Marshal.dump(offsets, f) }
  end
end

class String
  def display_width(ambiguous=1)
    #codepoints.inject(0){ |a,c|
    unpack('U*').inject(0){ |a,c|
      width = case Unicode::DisplayWidth.codepoint(c).width
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
