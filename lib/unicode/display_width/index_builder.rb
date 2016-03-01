require_relative '../display_width'

module Unicode
  module DisplayWidth
    module IndexBuilder
      def self.fetch!
        require 'open-uri'
        open("http://www.unicode.org/Public/UNIDATA/EastAsianWidth.txt") { |f|
          File.write(EAST_ASIAN_WIDTH_DATA_FILENAME, f.read)
        }
      end

      def self.build!
        data = File.open EAST_ASIAN_WIDTH_DATA_FILENAME
        data.rewind
        Dir.mkdir(DATA_DIR) unless Dir.exists?(DATA_DIR)
        east_asian_width_table = {}
        general_category_width_table = {}
        zero_width_category = "Mn"

        data.each_line{ |line|
          line =~ /^(\S+?);(\S+)\s+#\s(\S+).*$/
          if $1 && $2
            cps, width, category = $1, $2, $3
            if cps['..']
              Range.new(*cps.split('..').map{ |cp| cp.to_i(16) }).each{ |cp|
                east_asian_width_table[cp] = width.to_sym
                general_category_width_table[cp] = 0 if category == zero_width_category
              }
            else
              east_asian_width_table[cps.to_i(16)] = width.to_sym
              general_category_width_table[cps.to_i(16)] = 0 if category == zero_width_category
            end
          end
        }
        File.open(EAST_ASIAN_WIDTH_INDEX_FILENAME, 'wb') { |f| Marshal.dump(east_asian_width_table, f) }
        File.open(GENERAL_CATEGORY_WIDTH_INDEX_FILENAME, 'wb') { |f| Marshal.dump(general_category_width_table, f) }
      end
    end
  end
end
