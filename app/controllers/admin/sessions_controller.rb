# This controller handles the login/logout function of the site.  
class Admin::SessionsController < ApplicationController
  layout 'sessions'

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
      redirect_back_or_default('/admin')
      flash[:notice] = l(:admin_general, :logged_in)
    else
      flash[:notice] = l(:admin_general, :login_failed)
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = l(:admin_general, :logged_out)
    redirect_back_or_default(admin_login_path)
  end

end
