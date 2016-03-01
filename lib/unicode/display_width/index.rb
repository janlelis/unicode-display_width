require_relative 'constants'

module Unicode
  module DisplayWidth
    INDEX = Marshal.load(File.binread(INDEX_FILENAME))
  end
end
