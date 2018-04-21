require 'filewatcher'
require 'socket'
require './file_manager'
require './file_notifier'

class Client
  include FileNotifier

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
          FileManager.delete(file_dir)
        else
          FileManager.create_or_update(file_dir, bits)
        end
      }
    end
  end

  def send
    join

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

  def join
    puts "Enter your username:"
    username = $stdin.gets.chomp

    puts "Enter the directory where you will sync your files:"
    @dir = $stdin.gets.chomp

    @server.puts(username)
  end
end

server = TCPSocket.open('localhost', 3000)
Client.new(server)
