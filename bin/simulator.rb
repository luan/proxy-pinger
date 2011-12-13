require File.join('.', File.dirname(__FILE__), '..', 'lib/proxy_pinger')

def start_pingers(ports=[])
  pingers = []
  ports = ports.sort.reverse
  ports.each do |port|
    puts "starting port #{port}"
    nport = port + 1
    nport = nil if port == ports.first
    pingers << ProxyPinger.new(:port => port, :next => nport)
  end
  pingers << ProxyPinger.new(:next => ports.last)
  
  pingers.each do |pinger|
    if pinger == pingers.last
      pinger.nserver.puts("google.com")
      puts "(client) #{pinger.nserver.gets.chomp}"
      pinger.nserver.close
    else
      Thread.new { pinger.start }
    end
  end
end

pingers = (22222..22226).to_a
start_pingers(pingers)
