module Unicode
  module DisplayWidth
    VERSION = '0.3.1'.freeze
    DATA_DIRECTORY = File.join(File.dirname(__FILE__), '../../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + 'EastAsianWidth.index').freeze
  end
end
