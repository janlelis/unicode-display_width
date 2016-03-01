require_relative '../display_width'

module Unicode
  module DisplayWidth
    module IndexBuilder
      EAST_ASIAN_WIDTH_DATA_FILENAME = (DATA_DIRECTORY + 'EastAsianWidth.txt').freeze
      ZERO_WIDTH_CATEGORIES = %w[Mn Me]
      SPECIAL_WIDTHS = {}

      def self.fetch!
        require 'open-uri'
        open("http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt") { |f|
          File.write(EAST_ASIAN_WIDTH_DATA_FILENAME, f.read)
        }
      end

      def self.build!
        data = File.open(EAST_ASIAN_WIDTH_DATA_FILENAME)
        data.rewind
        Dir.mkdir(DATA_DIRECTORY) unless Dir.exists?(DATA_DIRECTORY)
        index = {}

        data.each_line{ |line|
          line =~ /^(\S+?);(\S+)\s+#\s(\S+).*$/
          if $1 && $2
            cps, width, category = $1, $2, $3
            if cps['..']
              Range.new(*cps.split('..').map{ |cp| cp.to_i(16) }).each{ |cp|
                index[cp] = is_zero_width?(category) ? 0 : width.to_sym
              }
            else
              index[cps.to_i(16)] = is_zero_width?(category) ? 0 : width.to_sym
            end
          end
        }
        index.merge! SPECIAL_WIDTHS
        File.open(INDEX_FILENAME, 'wb') { |f| Marshal.dump(index, f) }
      end

      def self.is_zero_width?(category)
        ZERO_WIDTH_CATEGORIES.include?(category)
      end
    end
  end
end
