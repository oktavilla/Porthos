# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include Porthos::AccessControl
  
  before_filter :login_from_cookie
  around_filter :set_current_user


  unless ActionController::Base.consider_all_requests_local
    rescue_from Exception, :with => :status_500
    rescue_from 'SecurityTransgression' do |e|
      head :forbidden
    end
    rescue_from ActionController::RoutingError, :with => :status_404
    rescue_from ActiveRecord::RecordNotFound,   :with => :status_404
  end
  

protected

  def status_404
    respond_to do |format| 
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => :not_found } 
      format.xml  { head(:not_found) } 
    end 
  end
  
  def status_500(exception)
    log_error(exception)
    respond_to do |format| 
      format.html { render :file => "#{RAILS_ROOT}/public/500.html", :status => 500 } 
      format.xml  { head(500) } 
    end 
  end

  def set_current_user
    User.current = current_user if logged_in?
    yield
    User.current = nil
  end

end
