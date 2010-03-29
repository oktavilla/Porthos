# This controller handles the login/logout function of the site.  
class User::SessionsController < ApplicationController
  include Porthos::Public
  before_filter :require_node, :only => [:new, :create, :forgot_password]
  layout 'public'

  # render new.html.erb
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      respond_to do |format|
        format.html do
          flash[:notice] = t(:logged_in, :scope => [:app, :general])
          redirect_back_or_default('/')
        end
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:failure] = t(:login_failed, :scope => [:app, :general])
          render :action => 'new'
        end
      end
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = t(:logged_out, :scope => [:app, :general])
    redirect_back_or_default(login_path)
  end
  
  def forgot_password 
  end
  
  def send_new_password
    if @user = User.find(:first, :conditions => ['email = ?', params[:email]])
      @user.generate_new_password!
      UserMailer.deliver_new_password(@user)
      flash[:notice] = t(:password_has_been_sent, :scope => [:app, :general])
    else
      flash[:notice] = t(:unable_to_find_user, :scope => [:app, :general])
    end
    render :action => 'forgot_password'
  end

  def token
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
