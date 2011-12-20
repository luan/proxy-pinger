# biblioteca socket do Ruby, contém classes para TCP e UDP
# utlizaremos aqui TCPSocket e TCPServer
require 'socket'

class ProxyPinger
  ##
  # Construtor, cria um Proxy Pinger dados os parametros:
  # port: porta na qual o servidor do proxy será aberto 
  #  (caso não seja o primeiro da corrente)
  # host: host ao qual o pinger se conctara (proximo servidor na corrente)
  # next: porta do próximo proxy pinger
  #  (nulo caso seja o último da corrente)
  # 
  # Estes parametros devem ser passados na hash options com as chaves da
  #   hash sendo os nomes acima.
  #
  # = Exemplo
  #   pinger = ProxyPinger.new(:port => 22222, :host => 192.168.1.7, :next => 22223)
  
  def initialize(options = {})
    # Coloca o valor default em host caso este não tenha sido definido
    options.merge! :host => "127.0.0.1"

    # apenas para log, guardamos a porta em uma atributo da instancia
    @port = options[:port]
    
    # caso tenha sido passada uma porta, iniciamos um servidor proxy pinger
    if options.include?(:port)
      @server = TCPServer.new("0.0.0.0", options[:port])
      puts "(#{@port}) server up" if @server
    else
      @server = nil
    end
    
    # @server = nil (cliente, primeiro pinger)
    
    # caso tenha sido passada uma porta para o proximo servidor
    # conecta-se a ele para repassar os pings
    if options.include?(:next) && options[:next]
      puts "connecting to server on #{options[:host]}:#{options[:next]}"
      @nserver = TCPSocket.new(options[:host], options[:next])
    else
      @nserver = nil
    end
    
    # @nserver = nil (servidor final, ultimo pinger)
  end
  
  ##
  # Método principal da thread do servidor.
  # Aqui acontece o loop do pinger, onde fica escutando possíveis clientes
  #
  
  def start
    # "loop do" é um loop infinito em Ruby
    loop do
      # Iniciamos uma nova thread para cada cliente
      # O comando Thread.start iniciará uma thread para o parametro passado
      # nomeando-o como definido no bloco |client|
      Thread.start(@server.accept) do |client|
        puts "(#{@port}) client connected"
        
        # Um loop infinito para cada cliente, para o caso de ser outro pinger
        # ele não morrerá até que o usuário pare sua execução, portanto
        # mantemos a conexão TCP aberta
        loop do
          # client.gets recebe uma linha de texto vinda do clientem
          # é tudo que precisamos aqui, ".chomp" remove final de linha caso
          # necessário
          host = client.gets.chomp
          puts "(#{@port}) got host '#{host}'"

          if @nserver
            # if @nserver será verdadeiro quando não for "nil"
            # portanto este servidor é um Proxy intermediário
            puts "(#{@port}) sending to next server"
            # @nserver.puts(host): envia a mensagem host para o servidor @nserver
            @nserver.puts(host)
            # esperamos aqui resposta do @nserver para podermos repassar ao cliente
            result = @nserver.gets.chomp
          else
            # @nserver = nil (servidor final, ultimo pinger)
            # sendo o último servidor devemos executar o ping propriamente dito
            # utilizamos o comando "ping" do unix para tal
            puts "(#{@port}) pinging host '#{host}'"
            result = system("ping -c 3 #{host}")
          end
          puts "(#{@port}) got result #{result.to_s}"
          if result == false || result == true
            result = (result) ? "#{host} is up" : "#{host} is down"
          end
          # sendo o último ou um intermediário, temos uma resposta aqui para passar
          # pra frente tal resposta serå devolvida recursivamente até que chegue no
          # primeiro cliente
          client.puts(result.to_s)
        end
      end
    end
  
    @nserver.close
  end
  
  ##
  # Este método é um getter para o @nserver, utlizaremos isto para fins do primeiro
  # cliente na corrente
  #
  
  def nserver
    @nserver
  end
end
