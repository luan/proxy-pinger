# biblioteca optparse do Ruby
# para facilitar o parsing das opções de linha de comando
require 'optparse'

# blblioteca proxy_pinger, desenvolvida para o trabalho
# essa biblioteca foi desenvolvida para confecção do trabalho, explicada no seu código
require File.join('.', File.dirname(__FILE__), '..', 'lib/proxy_pinger')

# interpretamos as opções de linha de comando
# o OptionParser faz tudo de presente, preciamos apenas definir algumas coisas
# como abaixo, definimos as opções:
#  -p PORT, --port PORT => porta do servidor TCP a ser criado
#  -n PORT, --next PORT => porta do próximo sevidor na corrente
#  -H HOST, --host HOST => host do próximo servidor na corrente
# 
# Todas as opções são facultativas, e assumirão valor padrão definido na classe
# ProxyPinger do arquivo lib/proxy_pinger.rb
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: proxy_pinger.rb [options]"

  opts.on("-p PORT", "--port PORT", "Server port") do |port|
    options[:port] = port
  end
  
  opts.on("-n PORT", "--next PORT", "Next server port") do |port|
    options[:next] = port
  end
  
  opts.on("-H HOST", "--host HOST", "Next server host (default: 127.0.0.1)") do |host|
    options[:host] = port
  end
end.parse!

# se existe a opção port então este é um servidor intermediário
if options.include? :port
  puts "starting port #{options[:port]}"
  # apenas instanciamos um novo pinger com as dadas opções passadas na linha de comando
  pp = ProxyPinger.new(options)
  # iniciamos seu loop até que seja interrompido pelo usuário
  # ou em caso de erro
  pp.start
# caso contrårio é o primeiro cliente na corrente
else
  puts "starting client"
  # apenas instanciamos um novo pinger com as dadas opções passadas na linha de comando
  pp = ProxyPinger.new(options)
  # o cliente é simples, apenas lê um host da entrada e requisita o ping
  # pp.nserver.puts(gets.chomp): semelhante ao que visto na classe, puts envia a mensagem
  # para o pp.nserver, que é o próximo servidor na corrente
  # gets.chomp lê da entrada, removendo quebras de linha o host
  pp.nserver.puts(gets.chomp)
  # esperamos resosta e mostramos o resultado na saída padrão
  puts "(client) #{pp.nserver.gets.chomp}"
  pp.nserver.close
end
