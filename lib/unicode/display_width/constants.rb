module Unicode
  module DisplayWidth
    VERSION = '1.0.5'
    UNICODE_VERSION = "8.0.0".freeze
    DATA_DIRECTORY = File.expand_path(File.dirname(__FILE__) + '/../../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + '/display_width.marshal.gz').freeze
  end
end
