class Message
  attr_reader :bits, :digested_file, :event, :filename, :string_message

  def initialize(string_message)
    splitted_message = string_message.split(': ')
    @string_message = string_message
    @filename = splitted_message.first
    @event = splitted_message[1].to_sym
    @bits = splitted_message[2]
    @digested_file = splitted_message[3]
  end
end
