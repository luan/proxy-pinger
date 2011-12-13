require 'socket'

class ProxyPinger
  def initialize(port = nil, nport = nil)
    @port = port
    
    if port
      @server = TCPServer.new("127.0.0.1", port)
      puts "(#{@port}) server up" if @server
    else
      @server = nil
    end
    
    if nport
      puts "connecting to server on port #{nport}"
      @nserver = TCPSocket.new("127.0.0.1", nport)
    else
      @nserver = nil
    end
  end
  
  def start
    loop do
      Thread.start(@server.accept) do |client|
        puts "(#{@port}) client connected"
        loop do
          host = client.gets.chomp
          puts "(#{@port}) got host '#{host}'"

          if @nserver
            puts "(#{@port}) sending to next server"
            @nserver.puts(host)
            result = @nserver.gets.chomp
          else
            puts "(#{@port}) pinging host '#{host}'"
            result = system("ping -c 3 #{host}")
          end
          puts "(#{@port}) got result #{result.to_s}"
          result = (result) ? "#{host} is up" : "#{host} is down"
          client.puts(result.to_s)
        end
      end
    end
  
    @nserver.close
  end
  
  def nserver
    @nserver
  end
end
