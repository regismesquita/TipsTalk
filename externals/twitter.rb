#This file and any other file in this folder should contain external functions
#This file is intended to implement a twitter tool.
#
ActiveRecord::Base.establish_connection(  
 :adapter => "sqlite3",  
 :database => "test.db",
)  

class Tipstalk < ActiveRecord::Base #Database containg O auth authorizations
end

class Twt
	def self.all
		@@instances ||= Hash.new
		@@instances
	end
	def self.get(email)
		if email.class != String
			email = email.node+"@"+email.domain
		end
		@@instances ||= Hash.new
		account = @@instances[email]
		account ||= Twt.new(email)
		return account
	end
	def initialize(email)
		user = Tipstalk.find_by_email(email)
		if(user)
			oauth = Twitter::OAuth.new('','')
			oauth.authorize_from_access(user.atoken,user.asecret)

			@email = email
			@base = Twitter::Base.new(oauth)
			@last_post = @base.friends_timeline.first
			@@instances ||= Hash.new
			@@instances.store(email,self) 
		else
			return nil
		end
	end
	def update(mensagem)
		begin
		@base.update(mensagem)
		rescue
		 puts @email+" base = "+@base.to_s
		end
	end
	def post_last(total)
		messages = Array.new
		puts "Resgatando tweet."
		mens = @base.friends_timeline.sort{|t1,t2| t1.id <=> t2.id}
		mens.reverse!
		total.to_i.times{
			ultimo = mens.shift
			if ultimo then messages.push('@'+ultimo.user.screen_name+' - '+ultimo.text) end
		}
		return messages
	end
	def verifq_tweet(im)
		@check_messages_cycle ||= Thread.new{
			while true
				sleep(10)
				puts "Verificando tweets alheios."
				lista = @base.friends_timeline.sort{|t1,t2| t1.id <=> t2.id}
				lista.each{|ultimo|
					if @last_post.id < ultimo.id
						@last_post = ultimo
						im.deliver(@email,'@'+ultimo.user.screen_name+' - '+ultimo.text)
					end
				}
			end
		}
	end
	def stop_check_tweet
		if @check_messages_cycle then @check_messages_cycle.exit end
	end
	def self.exit(email)
		Twt.get(email).stop_check_tweet
		@@instances.delete(email)
	end

end

Robot.add_method('start_twitter_bot_module',lambda{|mes,im|
	im.deliver(mes.from,"Inicializando funcoes de twitter")
	Thread.new do
		while true
			im.presence_updates.each do |pres|
				puts "Houve alteração: "+pres.inspect
				begin
 				  Twt.get(pres[0]).verifq_tweet(im)
				rescue Exception => e
					puts "Erro: "+e.message
					im.deliver(pres[0],"Sua validacao no twitter nao eh mais valida favor revalidar!")
				end
				if pres[1] == :unavailable
					Twt.exit(pres[0])
				end
			end
			sleep(3)
		end
	end
})


#Twitter robot functions
Robot.add_method("tweet",lambda{|mes,im|
	message = mes.body
	message['tweet']=''
	im.deliver(mes.from,"Tweeting")
	begin
		Twt.get(mes.from).update(message)
		im.deliver(mes.from,"Tweetado.")
rescue Exception => e
			puts "Erro: "+e.message
		im.deliver(mes.from,"Sua validacao no twitter nao eh mais valida favor revalidar!")
	end

})
Robot.add_method("last",lambda{|mes,im|
	message = mes.body
	total = message.split[1]
	if total.to_i.to_s == total
		begin
			messages = Twt.get(mes.from).post_last(total.to_i)
			messages.each{|message| im.deliver(mes.from,message)}
			im.deliver(mes.from,"Ultimas #{total} mensagens exibidas.")
		rescue Exception => e
			puts "Erro: "+e.message
			im.deliver(mes.from,"Sua validacao no twitter nao eh mais valida favor revalidar!")
		end
	else
		im.deliver(mes.from,"Voce deve digitar um numero com o comando last.")
	end
})


#Administrative Function
Robot.add_method("check-all",lambda{|mes,im|
	im.deliver(mes.from,Twt.all.inspect)
})
#Example External-function (Echo)
Robot.add_method("echo",lambda{|mes,im|
	message = mes.body
	message['echo']=''
	im.deliver(mes.from,message)
})
