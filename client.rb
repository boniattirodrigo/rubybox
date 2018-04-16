# s = File.binread("file.txt")
# bits = s.unpack("B*")

# File.open('file2.txt', 'wb') do|f|
#   f.write(bits.pack("B*"))
# end

require "socket"
class Client
  def initialize( server )
    @server = server
    @request = nil
    @response = nil
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        puts msg

        binary_file = msg.split(': ').last

        puts binary_file
        File.open("#{Time.now}.txt", 'wb') do|f|
          f.write([binary_file].pack("B*"))
        end

      }
    end
  end

  def send
    puts "Enter the username:"
    @request = Thread.new do
      loop {
        msg = $stdin.gets.chomp
        @server.puts( msg )
      }
    end
  end
end

server = TCPSocket.open( "localhost", 3000 )
Client.new( server )