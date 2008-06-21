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
      redirect_back_or_default('/')
      flash[:notice] = l(:general, :logged_in)
    else
      flash[:notice] = l(:general, :login_failed)
      render :action => 'new'
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = l(:general, :logged_out)
    redirect_back_or_default(login_path)
  end
  
  def forgot_password 
  end
  
  def send_new_password
    if @user = User.find(:first, :conditions => ['email = ?', params[:email]])
      @user.generate_new_password!
      UserMailer.deliver_new_password(@user)
      flash[:notice] = l(:general, :password_has_been_sent)
    else
      flash[:notice] = l(:general, :unable_to_find_user)
    end
    render :action => 'forgot_password'
  end

  def token
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

end
