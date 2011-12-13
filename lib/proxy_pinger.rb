require 'socket'

class ProxyPinger
  def initialize(options = {})
    options.merge!(
      :host => "127.0.0.1"
    )

    @port = options[:port]
    
    if options.include?(:port)
      @server = TCPServer.new("0.0.0.0", options[:port])
      puts "(#{@port}) server up" if @server
    else
      @server = nil
    end
    
    if options.include?(:next) && options[:next]
      puts "connecting to server on #{options[:host]}:#{options[:next]}"
      @nserver = TCPSocket.new(options[:host], options[:next])
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
