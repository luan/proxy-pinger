require 'optparse'
require File.join('.', File.dirname(__FILE__), '..', 'lib/proxy_pinger')

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-p PORT", "--port PORT", "Server port") do |port|
    options[:port] = port
  end
  
  opts.on("-n PORT", "--next PORT", "Next server port") do |port|
    options[:next] = port
  end
end.parse!

if options.include? :port
  puts "starting port #{options[:port]}"
  pp = ProxyPinger.new(options[:port], options[:next])
  pp.start
else
  puts "starting client"
  pp = ProxyPinger.new(nil, options[:next])
  pp.nserver.puts(gets.chomp)
  puts "(client) #{pp.nserver.gets.chomp}"
  pp.nserver.close
end
