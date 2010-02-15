require 'registration_methods'
class RegistrationsController < ApplicationController
  include Porthos::Public
  include RegistrationMethods
  layout 'public'
  
  def show
    @registration = Registration.find(session[:current_registration])
    @full_render = true
    session[:current_registration] = nil
    respond_to do |format|
      format.html do        
        load_page_objects
        @page = @registration.registration_form.page
        render :template => 'pages/show' 
      end
    end
  end
    
  def create
    type = params[:registration_type]
    @registration = Registration.new_from_type(type, params[:registration])
    @registration.ip_address = request.remote_ip
    @registration.session_id = porthos_session_id
    @registration.env = request.env

    if @registration.save
      approved_url = params[:approved_url] || http_url_from_path(registration_path(:id => @registration.to_url))
      session[:current_registration] = @registration.id

      if @registration.payable?
        Conversion.from_payment(session[:measure_point], @registration) if session[:measure_point]
        @payment = Payment.for_payable(@registration)
        @payment.save
        
        @redirection_url = case
        when @payment.direct_payment?
          @payment.update_attributes(:status => 'Redirected')
          @payment.integration_url({
            :approved_url => approved_url,
            :declined_url => params[:declined_url] || registration_url(:id => @registration.to_url, :denied => true)
          })
        when @payment.creditcard_payment?
          @payment.update_attributes(:status => 'Redirected')
          session[:registration_return_path] = approved_url
          https_url_from_path((request.format.to_sym == :xml) ? new_payment_path(:public_id => @registration.public_id) : new_payment_path)
        when @payment.invoice_payment?
          registration_path(:id => @registration.to_url)
        end
      else
        Conversion.from_click(session[:measure_point], @registration) if session[:measure_point]
        @redirection_url = registration_path(:id => @registration.to_url)
      end
      
      @registration.update_attribute(:return_path, approved_url)
      
      respond_to do |format|
        format.html { redirect_to @redirection_url }
        format.xml { render :layout => false, :status => :created }
      end
    else
      respond_to do |format|
        format.html do
          load_page_objects
          render :template => 'pages/show'
        end
        format.xml { render :xml => @registration.errors.to_xml, :status => 422 }
      end
    end
  end
  
  def update
    check_for_injected_params
    @registration = Registration.find(:first, :conditions => ['public_id = ?', params[:id]])
    session[:current_registration] = @registration.id
    @registration.update_attributes(params[:registration])
    respond_to do |format|
      format.html { redirect_to registration_path(:id => @registration.to_url) }
    end
  end

protected

  def load_page_objects
    @node      = @registration.node
    @page      = params[:page_slug].blank? ? @node.resource : @node.resource.pages.find_by_slug(params[:page_slug])
    require_node
  end
  
  def check_for_injected_params
    return unless params[:registration]
    approved_keys = [
      'come_from'
    ]
    params[:registration].stringify_keys.keys.each do |key|
      raise SecurityTransgression unless approved_keys.include?(key)
    end
  end
end
