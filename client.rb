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
        bits = msg.last

        File.open("#{@dir}/#{filename}", 'wb') do|f|
          f.write([bits].pack("B*"))
        end
      }
    end
  end

  def send
    puts "Enter the username:"
    username = $stdin.gets.chomp

    puts "Enter the dir:"
    @dir = $stdin.gets.chomp

    @server.puts(username)

    @request = Thread.new do
      Filewatcher.new(@dir).watch do |filename, event|
        digested_file = digest(filename)
        puts digested_file

        unless @list.include? digested_file
          @list << digested_file
          s = File.binread(filename)
          bits = s.unpack("B*").first
          file = filename.split(@dir).last

          message = "#{file}: #{event}: #{bits}"
          @server.puts(message)
        end
      end
    end
  end

  def digest(file_dir)
    sha256 = Digest::SHA256.file file_dir
    file_name_digested = Digest::SHA256.hexdigest file_dir
    Digest::SHA256.hexdigest "#{file_name_digested}#{sha256.hexdigest}"
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )