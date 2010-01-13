# Version 0.1 (TipsBot) First Release
# This Software Basically creates a Google Talk Bot.

require 'rubygems' #Para acessar as gems abaixo
require 'twitter'
require 'active_record' # Acesso ao banco de dados.
require 'xmpp4r-simple' # Gem para acesso ao Jabber simplificada.

def require_all_on(dir)
	$LOAD_PATH.unshift(dir)
	Dir[File.join(dir, "*.rb")].each {|file| puts "loading #{file.to_s}";require dir+"/"+File.basename(file)}
end

puts "Requiring libs done. Now will load bot's core."
require_all_on('core')
puts "Loading External Functions."
require_all_on('externals')

puts "Starting Bot."
@robot = Robot.new("user",'password')
puts "Connected."


puts "Entering in Activity."
while true
	sleep(5)
	@robot.verificarMensagens
end
