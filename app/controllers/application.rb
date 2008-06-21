# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  filter_parameter_logging :card_number, :card_expiry_month, :card_expiry_year, :card_number_cvc, :payment_type

  include ExceptionNotifiable
  include Porthos::AccessControl
  
  before_filter :login_from_cookie
  consider_local "213.115.77.90"

  #rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, :with => :status_404
  rescue_from 'SecurityTransgression' do |e|
    head :forbidden
  end

protected

  def status_404
    respond_to do |format| 
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found' } 
      format.xml  { head(:not_found) } 
    end 
  end

end
