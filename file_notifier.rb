require './file_manager'

module FileNotifier
  def send_delete_file_message(filename, destination)
    file = remove_path_for(filename)
    destination.puts("#{file}: deleted")
  end

  def send_create_or_update_file_message(filename, event, destination)
    digested_file = FileManager.digest(filename)
    binread_file = File.binread(filename)
    bits = binread_file.unpack("B*").first
    file = remove_path_for(filename)

    destination.puts("#{file}: #{event}: #{bits}: #{digested_file}")
  end

  private

  def remove_path_for(filename)
    filename.split(@dir).last
  end
end
