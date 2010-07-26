# Version 0.1 (TipsBot) First Release
# This Software Basically creates a Google Talk Bot.

require 'rubygems' #Para acessar as gems abaixo
require 'twitter'
require 'active_record' # Acesso ao banco de dados.
require 'xmpp4r-simple' # Gem para acesso ao Jabber simplificada.
require 'aux'
include Aux

puts "Requiring libs done. Now will load bot's core."
require_all_on('core')
puts "Loading External Functions."
require_all_on('externals')

puts "Starting Bot."
login_info = read_login_info()
@robot = Robot.new(login_info)

puts "Connected."


puts "Entering in Activity."
while true
  sleep(5)
  @robot.receiveMessages
  @robot.processMessages
end
