module Unicode
  module DisplayWidth
    VERSION = '1.5.0'
    UNICODE_VERSION = "12.1.0".freeze
    DATA_DIRECTORY = File.expand_path(File.dirname(__FILE__) + '/../../../data/').freeze
    INDEX_FILENAME = (DATA_DIRECTORY + '/display_width.marshal.gz').freeze
  end
end
