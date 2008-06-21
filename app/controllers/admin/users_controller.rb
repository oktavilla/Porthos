class Admin::UsersController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'users'

  def index
    admins
  end
  
  def admins
    @role = Role.find_or_create_by_name('Admin')
    @users = @role.users.find(:all, :order => "last_name, first_name")
    respond_to do |format|
      format.html { render :action => 'index' }
    end
  end
  
  def public
    @role = Role.find_or_create_by_name('Public')
    @users = @role.users.find(:all, :order => "last_name, first_name")
    respond_to do |format|
      format.html { }
    end
  end
  
  def new
    @user = User.new
    @role = Role.find_or_create_by_name('Admin')
  end
  
  def new_public
    @user = User.new
    @role = Role.find_or_create_by_name('Public')
    render :action => 'new'
  end

  def create
    @user = User.new(params[:user])
    @role = Role.find_or_create_by_name(params[:role])
    @user.save!
    @user.roles << @role
    flash[:notice] = "#{@user.login} #{l(:admin_general, :saved)}"
    respond_to do |format|
      format.html { redirect_to params[:return_to] || admin_users_path }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end

  def edit
    @user = User.find(params[:id])
    raise SecurityTransgression unless current_user.can_edit?(@user)
  end

  def update
    @user = User.find(params[:id])
    raise SecurityTransgression unless current_user.can_edit?(@user)
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "#{@user.name} #{l(:admin_general, :saved)}"
        format.html { redirect_to params[:return_to] || admin_users_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    raise SecurityTransgression unless current_user.can_destroy?(@user)
    @user.destroy
    flash[:notice] = "#{@user.login} #{l(:admin_general, :deleted)}"
    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

end
