class Message
  attr_accessor :message,:im
  def initialize(message,im)
    @message = message
    @im = im
  end

  def execute
    if self.get_method
      self.call_method_from_message
    else
      @im.deliver(@message.from,"Function #{metodo.inspect} does not exist")
      @im.deliver(@message.from,"Avaliable Functions: #{@@methods.keys.inspect}.") if $DEBUG
    end
  end

  def get_method
    method_name = message.body.split(' ').first 
    method = Robot.bot_methods[method_name]
  end

  def call_method_from_message
    begin
      self.get_method.call(@message,@im)
    rescue Exception => e
      @im.deliver(@message.from,"Failed to execute function")
      @im.deliver(@message.from,"Exception #{e.message}") if $DEBUG
    end
  end

end
