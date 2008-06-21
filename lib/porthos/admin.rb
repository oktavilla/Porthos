module Porthos
  module Admin

    # Set remember_uri as an after_filter
    def self.included(base)
      base.send :include, Porthos::AccessControl
      base.send :skip_before_filter, :remember_uri, :only => [:edit, :create, :update, :destroy, :sort]
    end

  
  protected

    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to admin_login_path
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
  
    # Overide the authenitcated system authorized do only admit admins
    def authorized?
      current_user.admin?
    end

  end
end