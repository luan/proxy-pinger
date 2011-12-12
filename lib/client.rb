require 'socket'  

client = TCPSocket.new("127.0.0.1", 28561)
puts client.readline.chomp
client.close