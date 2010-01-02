# Versão 2.1 alpha , TipsTalk

# Software basicamente cria um usuario no gtalk que permite ao usuario postar no twitter, pode ser facilmente expandido para outras funções

# This Software Basically connects to as a google talk user and allow through messages to users post messsages on twitter , can be easily expanded into new functions.

#O script deverá varrer a classe Tipstalk e capturar todas as pessoas, verificar quais já estão adicionadas , mandar convite as que não estão e então iniciar Thread que ficará enviando ao usuario os seus ultimos tweets e twittando para a pessoa, thread deverá ficar identificado em uma hash para o script verificar se a pessoa não já possui uma conexão aberta e se não tiver iniciar uma em loop que verifica a classe tweet talk.

#Tudo acima foi feito na versão 1.0 ,otimizado e transformado para classes na 1.1, bugs corrigidos na 1.2 e convertido pra oAuth na 2.0 e código "limpo"(Ainda falta limpar algumas coisas....) na 2.1 .

#This code is licensed under the terms of GPLv3.
#Este código esta licenciado sob os termos da GPLv3.

require 'rubygems' #Para acessar as gems abaixo
require 'active_record' # Acesso ao banco de dados.
require 'twitter' #Gem do Twitter, inclui auth por http e por oAuth.
require 'xmpp4r-simple' # Gem para acesso ao Jabber simplificada.
  
puts "Requires concluidos"

puts "Acionando base de dados"

class TipsbotBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(  
   :adapter => "",  
   :host => "",
   :database => "",
   :username => "",
   :password => ""
  )
end

class Tipstalk < TipsbotBase #Acesso a tabela do site , esta tabela contem as sessões já autorizadas em oAuth.
end

puts "Criando classe Im"
class Im
  attr_accessor :im,:lista_amigos,:lista_proc,:lista_mens
	def initialize(usuario,senha)
		@im = Jabber::Simple.new(usuario,senha)
		@im.accept_subscriptions=true
		@lista_amigos = Array.new 
		@lista_proc = Hash.new
		@lista_mens = Hash.new
	end
#Functions that are going to be used later by the user
  
#Last tweets.
  def last(mes)
    @im.deliver(mes.from,'pegando ultimas mensagens...')
		begin
		  mens = mes.body
			@lista_proc[mes.from.node+'@'+mes.from.domain].post_last(mens.split[1])
			@im.deliver(mes.from,'Exibidas ultimas '+mens.split[1]+' mensagens.')
		rescue Exception => e
			@im.deliver(mes.from,'Ocorreu um erro ao tentar resgatar as mensagens tente novamente em alguns minutos.'+e.message)
		end
  end
#Tweet Something.
  def tweet(mes)
    @im.deliver(mes.from,'tweeting...')
		begin
		  mens = mes.body
			mens['tweet ']=''
			@lista_proc[mes.from.node+'@'+mes.from.domain].update(mens)
			@im.deliver(mes.from,'tweetado.')
		rescue
			@im.deliver(mes.from,'Ocorreu um erro ao tentar tweetar tente novamente em alguns minutos.')
		end
  end
  #Verify if there's any new message sent by the user.
	def verificarMensagens
			puts "Verificando mensagens enviadas."
			if @im.received_messages?
				@im.received_messages.each do |mes|
				  @im.deliver(mes.from,"Processando! ")
				#TO-DO: Verify if the command is valid in order to avoid dangerous acts from the user.
				  mes.body.sub(/[^ ]*/){|x| puts method(x).call(mes) }
        end
			end
	end
end

puts "Criando classe Twt"
class Twt
	def initialize(email,token,secret)
		@email = email
		#@user = user
		oauth = Twitter::OAuth.new('siC91Kg0CL1TXD5FA7YA','OYkkc8Yo0r8TLAPkBGdrXvUcn5J3ZP638h10Yy0Vw')
		oauth.authorize_from_access(token,secret)
		#httpauth = Twitter::HTTPAuth.new(user, pass)
		#@pass = pass
		@base = Twitter::Base.new(oauth)
		@last_post = @base.friends_timeline.first
		$lista_mens[email] = Array.new
	end
	def tweetQueue()
		$lista_mens[email].each do |mensagem|
			self.update(mensagem)
		end
		$lista_mens[email] = Array.new
	end
	def update(mensagem)
		@base.update(mensagem)
	end
	def post_last(total)
		puts "Resgatando tweet."
		mens = @base.friends_timeline.sort{|t1,t2| t1.id <=> t2.id}
		mens.reverse!
		total.to_i.times{
			ultimo = mens.shift
			$im.deliver(@email,'@'+ultimo.user.screen_name+' - '+ultimo.text)
		}
	end
	def verifq_tweet()
		puts "Verificando tweets alheios."
		lista = @base.friends_timeline.sort{|t1,t2| t1.id <=> t2.id}
		lista.each{|ultimo|
			if @last_post.id < ultimo.id
				@last_post = ultimo
				$im.deliver(@email,'@'+ultimo.user.screen_name+' - '+ultimo.text)
			end
		}
	end
	def finish
		$lista_proc.delete(email)
	end
end



puts "Acionada"
puts "Conectando ao Jabber"
@im = Im.new("user@gmail.com","password") #The user and password that is going to be used by your software in gtalk.
puts "Conectado"

puts "fim de criacao e iniciando while"
#Don't remember why is this function outside the IM class , but whatever , no time to refactor it in.
def atualizaAmigos
  im = @im
  #Monta/Atualiza lista de amigos.
	puts "Verificando alterações de amigos."
	im.im.presence_updates.each do |pres|
		puts "Houve alteração: "+pres.inspect
		im.lista_amigos << pres[0]
		if pres[1] == :unavailable
			im.lista_proc.delete(pres[0])
			im.lista_amigos.delete(pres[0]) 
		end
	end

	im.lista_amigos.uniq!

	puts "Monta lista de pessoas ainda não adicionadas e as convida."
	convidar = Tipstalk.all.map{|talk| if !im.lista_amigos.member? talk.email then talk.email end}
	convidar.delete(nil)
	convidar.each{|email| 
		 im.im.add(email)
		 puts "Adicionei: "+email
	}

	puts "pega lista de processos e cria um novo processo se necessario."
	im.lista_amigos.each{|email|
		print im.lista_proc.inspect
		if !im.lista_proc[email] && Tipstalk.find_by_email(email)
			puts "Foi necessario"
			puts email
			begin
				Tipstalk.all
				user = Tipstalk.find_by_email(email)
				im.lista_proc[email] = Twt.new(email,user.atoken,user.asecret) unless !user
			rescue
				 puts "erro provavelemnte não autorizado "
			end
			puts "para o "+email
			
		end
	}
end
im = @im
puts "Rodando!"
Tipstalk.all
Thread.new{ im.verificarMensagens }
atualizaAmigos
while true
	puts "Run bitch!"
	Thread.new{
		Tipstalk.all #atualiza BD
		im.lista_proc.each{|email,amig| Thread.new{amig.verifq_tweet} }#Recebe Tweets
	}
	5.times do 
		sleep 6
		im.verificarMensagens #Used here there'll be a delay on user sent messages you can also remove this line and set a loop inside the "verificarMensagens" method so at the thread creation you'll start a loop and there'll be a minimal response time.
		atualizaAmigos   
		im.lista_proc.each{|email,amig| Thread.new{amig.tweetQueue} }
	end #Envia Tweets		
	puts "Runnou."
end
