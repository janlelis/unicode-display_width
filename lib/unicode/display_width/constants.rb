module Unicode
  module DisplayWidth
    VERSION = '1.1.2'
    UNICODE_VERSION = "9.0.0".freeze
    DATA_DIRECTORY = File.expand_path(File.dirname(__FILE__) + '/../../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + '/display_width.marshal.gz').freeze
  end
end
