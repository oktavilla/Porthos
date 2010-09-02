# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Redirects
  def self.call(env)
    redirect = Redirect.connection.select_all("SELECT * FROM redirects WHERE path = '#{env['PATH_INFO']}'").first
    if redirect && (redirect_path = redirect['target'])
      if not env['QUERY_STRING'].blank?
        if redirect_path.include?('?')
          redirect_path.gsub!('?', "?#{env['QUERY_STRING']}&")
        else
          redirect_path << "?#{env['QUERY_STRING']}"
        end
      end
      [301, {'Content-Type' => 'text/html', 'Location' => redirect_path}, ['You are being redirected.']]
    else
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    end
  end
end
