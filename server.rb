require 'socket'

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    run
  end

  def run
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
      puts "File: #{client_message[0]} | Event: #{client_message[1]}"

      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts msg
        end
      end
    }
  end
end

Server.new(3000, 'localhost')
