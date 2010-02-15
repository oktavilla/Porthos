# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Redirects
  def self.call(env)
    redirect = Redirect.connection.select_all("SELECT * FROM redirects WHERE path = '#{env["PATH_INFO"]}'").first
    if redirect && (redirect_path = redirect['target'])
      [302, {'Content-Type' => 'text/html', 'Location' => redirect_path}, ['You are being redirected.']]
    else
      [404, {'Content-Type' => 'text/html'}, ['Not Found']]
    end
  end
end
