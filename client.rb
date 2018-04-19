require 'digest'
require 'filewatcher'
require 'socket'

class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    @dir = nil
    @list = []
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp.split(': ')

        filename = msg.first
        event = msg[1]
        bits = msg.last
        file_dir = "#{@dir}/#{filename}"

        if event == 'deleted'
          delete_file(file_dir)
        else
          create_or_update_file(file_dir, bits)
        end
      }
    end
  end

  def send
    join_user

    @request = Thread.new do
      Filewatcher.new(@dir).watch do |filename, event|
        if event == :deleted
          send_delete_file_message(filename)
        else
          send_create_or_update_file_message(filename, event)
        end
      end
    end
  end

  private

  def join_user
    puts "Enter the username:"
    username = $stdin.gets.chomp

    puts "Enter the dir:"
    @dir = $stdin.gets.chomp

    @server.puts(username)
  end

  def remove_path_for(filename)
    filename.split(@dir).last
  end

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

  def delete_file(filename)
    File.delete(filename) if File.exists?(filename)
  end

  def create_or_update_file(file_dir, bits)
    File.open(file_dir, 'wb') { |f| f.write([bits].pack("B*")) }
  end

  def digest(file_dir)
    sha256 = Digest::SHA256.file file_dir
    file_name_digested = Digest::SHA256.hexdigest file_dir
    Digest::SHA256.hexdigest "#{file_name_digested}#{sha256.hexdigest}"
  end
end

server = TCPSocket.open('localhost', 3000)
Client.new(server)
