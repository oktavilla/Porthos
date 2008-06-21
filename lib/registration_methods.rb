module RegistrationMethods
  
  def https_url_from_path(path)
    port = case RAILS_ENV
    when 'production'  : ''
    when 'staging'     : ':444'
    when 'development' : ':3000'
    else
      ''
    end
    "#{(RAILS_ENV == 'development' ? 'http' : 'https')}://#{request.host}#{port}#{path}"  
  end
  
  def http_url_from_path(path)
    "http://#{request.host}#{path}"  
  end
  
end