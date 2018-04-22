require 'socket'
require './file_manager'
require './file_notifier'

class Server
  include FileNotifier

  def initialize(port, ip)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:clients] = @clients
    @dir = nil
    @files = {}
    run
  end

  def run
    set_up_server_directory

    loop {
      Thread.start(@server.accept) do | socket |
        username = socket.gets.chomp.to_sym
        check_if_client_already_is_registered!(username, socket)
        register_client(username, socket)
        send_all_files_to_the_new_client(socket)
        listen_client_messages(username, socket)
      end
    }.join
  end

  def listen_client_messages(username, socket)
    loop {
      message = socket.gets.chomp
      client_message = message.split(': ')

      filename = client_message.first
      event = client_message[1]
      bits = client_message[2]
      digested_file = client_message[3]

      if !@files.key?(filename) || event == 'deleted' || (@files.key?(filename) && @files[filename] != digested_file)
        puts "#{username} | #{event} | #{filename}"

        if event == 'deleted'
          @files.delete(filename)
        else
          @files[filename] = digested_file
        end

        update_file_in_server(filename, event, bits)
        broadcast(from_username: username, with_message: message)
      end
    }
  end

  private

  def check_if_client_already_is_registered!(username, socket)
    @connections[:clients].each do | client_username, client_socket |
      if username == client_username || socket == client_socket
        Thread.kill self
      end
    end
  end

  def register_client(username, socket)
    puts "#{username} #{socket}"
    @connections[:clients][username] = socket
  end

  def update_file_in_server(filename, event, bits)
    file_dir = "#{@dir}/#{filename}"

    if event == 'deleted'
      FileManager.delete(file_dir)
    else
      FileManager.create_or_update(file_dir, bits)
    end
  end

  def broadcast(from_username:, with_message:)
    @connections[:clients].each do | client_username, client_socket |
      client_socket.puts with_message if client_username != from_username
    end
  end

  def send_all_files_to_the_new_client(socket)
    @files.each do | filename, _ |
      send_create_or_update_file_message("#{@dir}/#{filename}", 'created', socket)
    end
  end

  def set_up_server_directory
    puts 'Set up the directory where the server will save the synced files:'

    @dir = $stdin.gets.chomp
  end
end

Server.new(3000, 'localhost')
