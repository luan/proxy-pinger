require 'socket'

port = 21317
server = nil

while server.nil?
  begin
    server = TCPServer.new("127.0.0.1", port)
  rescue
    port += 1
  end
end

puts "running in port #{port}"

loop do  
  Thread.start(server.accept) do |client|
    puts "#{client} is accepted"
    client.puts Time.now
    puts "#{client} is gone"
    client.close
  end
end