require_relative 'constants'

module Unicode
  module DisplayWidth
    module IndexBuilder
      EAST_ASIAN_WIDTH_DATA_FILENAME = (DATA_DIRECTORY + 'EastAsianWidth.txt').freeze
      IGNORE_CATEGORIES = %w[Cs Co Cn]
      ZERO_WIDTH_CATEGORIES = %w[Mn Me Cf]
      ZERO_WIDTH_CODEPOINTS = [*0x1160..0x11FF]
      SPECIAL_WIDTHS = {
        0x0    =>  0, # \0 NULL
        0x5    =>  0, #    ENQUIRY
        0x7    =>  0, # \a BELL
        0x8    => -1, # \b BACKSPACE
        0xA    =>  0, # \n LINE FEED
        0xB    =>  0, # \v LINE TABULATION
        0xC    =>  0, # \f FORM FEED
        0xD    =>  0, # \r CARRIAGE RETURN
        0xE    =>  0, #    SHIFT OUT
        0xF    =>  0, #    SHIFT IN
        0x00AD =>  1, #    SOFT HYPHEN
      }

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
            next if IGNORE_CATEGORIES.include?(category)
            if cps['..']
              codepoints = Range.new(*cps.split('..').map{ |cp| cp.to_i(16) })
            else
              codepoints = [cps.to_i(16)]
            end

            codepoints.each{ |cp|
              index[cp] = is_zero_width?(category, cp) ? 0 : width.to_sym
            }
          end
        }

        index.merge! SPECIAL_WIDTHS
        File.open(INDEX_FILENAME, 'wb') { |f| Marshal.dump(index, f) }
      end

      def self.is_zero_width?(category, cp)
        ( ZERO_WIDTH_CATEGORIES.include?(category) &&
            [cp].pack('U') !~ /\p{Cf}(?<=\p{Arabic})/ ) ||
          ZERO_WIDTH_CODEPOINTS.include?(cp)
      end
    end
  end
end
