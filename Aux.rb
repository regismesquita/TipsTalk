module Aux
  def require_all_on(dir)
  $LOAD_PATH.unshift(dir)
  Dir[File.join(dir, "*.rb")].each {|file|
    begin
      puts "loading #{file.to_s}";require dir+"/"+File.basename(file)
    rescue Exception => e
      puts "#{file} was not loaded , error: #{e.message}"
    end
  }
  end

  def read_login_info
    config_file = File.open('config.yml')
    config_info = YAML::load(config_file)
    login_info = config_info['gtalk']
    return login_info
  end
end
