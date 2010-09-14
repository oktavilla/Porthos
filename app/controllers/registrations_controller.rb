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
        unless @page.rendered_body.blank?
         render :inline => @page.rendered_body, :layout => true
        else
          @full_render = true
          render :template => 'pages/show'
        end
      end
    end
  end
    
  def create
    type = params[:registration_type]
    @registration = Registration.new_from_type(type, params[:registration])
    @registration.ip_address = request.remote_ip
    @registration.session_id = porthos_session_id
    @registration.env = request.env
    
    if !logged_in? && @registration.should_create_user?
      @user = User.new(params[:user])
      @user.sync_with_registration(@registration)
      @user.roles << Role.find_or_create_by_name('Public')
      @user.save!
      @registration.user_id = @user.id
      self.current_user = @user
    end

    @registration.save!

    approved_url = params[:approved_url] || http_url_from_path(registration_path(:id => @registration.to_url))
    session[:current_registration] = @registration.id

    @redirection_url = registration_path(:id => @registration.to_url)
    
    @registration.update_attribute(:return_path, approved_url)
    
    respond_to do |format|
      # force registration validation
      @registration.valid?
      format.html { redirect_to @redirection_url }
      format.xml { render :layout => false, :status => :created }
    end
      
  rescue ActiveRecord::RecordInvalid => e
            
    respond_to do |format|
      format.html do
        load_page_objects
        unless @page.rendered_body.blank?
         render :inline => @page.rendered_body, :layout => true
        else
          @full_render = true
          render :template => 'pages/show'
        end
      end
      format.xml { render :xml => @registration.errors.to_xml, :status => 422 }
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
