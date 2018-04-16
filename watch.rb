require 'filewatcher'

Filewatcher.new('watch/').watch do |filename, event|
    puts filename
    puts event
end
