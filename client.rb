require 'filewatcher'
require 'socket'
require './file_manager'
require './file_notifier'
require './message'

class Client
  include FileNotifier

  def initialize(server)
    @server = server
    @request = nil
    @response = nil
    @dir = nil
    @files = {}
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        string_message = @server.gets.chomp
        message = Message.new(string_message)
        file_dir = "#{@dir}/#{message.filename}"

        if message.event == :deleted
          FileManager.delete(file_dir)
        else
          FileManager.create_or_update(file_dir, message.bits)
        end
      }
    end
  end

  def send
    join

    @request = Thread.new do
      Filewatcher.new("#{@dir}/*.*").watch do |filename, event|
        check_if_file_was_renamed(filename, event)

        if event == :deleted
          @files.delete(filename)
          send_delete_file_message(filename, @server)
        else
          @files[filename] = FileManager.digest(filename)
          send_create_or_update_file_message(filename, event, @server)
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

    initial_files = Dir.glob("#{@dir}/*.*")

    @server.puts(username)

    send_all_files_to_server(initial_files)
  end

  def send_all_files_to_server(files)
    files.each do |filename|
      @files[filename] = FileManager.digest(filename)
      send_create_or_update_file_message(filename, :created, @server)
    end
  end

  def check_if_file_was_renamed(filename, event)
    @files.each do |file, content|
      new_file = event == :created
      return nil unless new_file
      same_content = content == FileManager.digest(filename)
      diferent_filename = filename != file
      was_removed = !File.exists?(file)

      if new_file && same_content && diferent_filename && was_removed
        @files.delete(file)
        send_delete_file_message(file, @server)
      end
    end
  end
end

server = TCPSocket.open('localhost', 3000)
Client.new(server)
