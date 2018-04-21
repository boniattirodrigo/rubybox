class FileManager
  class << self
    def create_or_update(filename, bits)
      File.open(filename, 'wb') { |f| f.write([bits].pack("B*")) }
    end

    def delete(filename)
      File.delete(filename) if File.exists?(filename)
    end
  end
end
