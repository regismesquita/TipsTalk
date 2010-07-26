#Administrative Function
Robot.add_method("check-all",lambda{|mes,im|
  im.deliver(mes.from,Twt.all.inspect)
})

Robot.add_method('debug-on',lambda{|mes,im|
$DEBUG = true
im.deliver(mes.from,"debug enabled")
})

Robot.add_method('debug-off',lambda{|mes,im|
$DEBUG = false
im.deliver(mes.from,"debug disabled")
})

#Example External-function (Echo)
Robot.add_method("echo",lambda{|mes,im|
  message = mes.body
  message['echo']=''
  im.deliver(mes.from,message)
})
