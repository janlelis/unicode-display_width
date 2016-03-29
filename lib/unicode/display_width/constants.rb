module Unicode
  module DisplayWidth
    VERSION = '1.0.3'.freeze
    DATA_DIRECTORY = File.join(File.dirname(__FILE__), '../../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + 'unicode-width.index').freeze
  end
end
