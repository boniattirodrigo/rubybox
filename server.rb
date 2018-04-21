require 'socket'
require './file_manager'

class Server
  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    @dir = nil
    run
  end

  def run
    set_dir

    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            Thread.kill self
          end
        end

        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages(username, client)
    loop {
      msg = client.gets.chomp
      client_message = msg.split(": ")

      filename = client_message.first
      event = client_message[1]
      bits = client_message.last
      file_dir = "#{@dir}/#{filename}"

      if event == 'deleted'
        FileManager.delete(file_dir)
      else
        FileManager.create_or_update(file_dir, bits)
      end
      puts "File: #{filename} | Event: #{event}"

      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts msg
        end
      end
    }
  end

  def set_dir
    puts 'Set up the directory where the server will save the synced files:'

    @dir = $stdin.gets.chomp
  end
end

Server.new(3000, 'localhost')
