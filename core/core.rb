#Core class , Robot base.
require 'message.rb'
class Robot
  attr_accessor :im,:lista_amigos,:lista_proc,:lista_mens
  def addMessage(message)
    Message.new(message,@im)
  end
  def initialize(login_info)
    usuario = login_info['username']
    senha = login_info['password']
    @im = Jabber::Simple.new(usuario,senha)
    @im.accept_subscriptions=true
    @lista_mens = Array.new
    @@methods ||= Hash.new
    puts "Main Class Loaded."
  end
  #Functions that are going to be used later by the user
  def self.add_method(name,function)
    @@methods ||= Hash.new
    @@methods.store(name,function)
    puts "Method #{name} added."
  end
  def self.bot_methods
    @@methods
  end
  def receiveMessages
    if @im.received_messages?
      @im.received_messages.each do |message|
       @lista_mens.push( addMessage(message) )
      end
    end
  end

  def processMessages
    while !@lista_mens.empty?
      message = @lista_mens.shift
      message.execute 
    end
  end

end
