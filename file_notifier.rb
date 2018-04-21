require 'digest'

module FileNotifier
  def send_delete_file_message(filename)
    file = remove_path_for(filename)
    @server.puts("#{file}: deleted")
  end

  def send_create_or_update_file_message(filename, event)
    digested_file = digest(filename)

    unless @list.include? digested_file
      @list << digested_file
      binread_file = File.binread(filename)
      bits = binread_file.unpack("B*").first
      file = remove_path_for(filename)

      @server.puts("#{file}: #{event}: #{bits}")
    end
  end

  private

  def remove_path_for(filename)
    filename.split(@dir).last
  end

  def digest(filename)
    sha256 = Digest::SHA256.file filename
    file_name_digested = Digest::SHA256.hexdigest filename
    Digest::SHA256.hexdigest "#{file_name_digested}#{sha256.hexdigest}"
  end
end
