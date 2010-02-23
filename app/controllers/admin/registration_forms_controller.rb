class Admin::RegistrationFormsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def index
    @registration_forms = RegistrationForm.find(:all, :order => 'name')
  end
  
  def show
    edit
    render :action => :edit
  end
  
  def new
    @role = Role.find_or_create_by_name('Admin')
    @users = @role.users.find(:all, :order => "last_name, first_name")
    @registration_form = RegistrationForm.new
    respond_to do |format|
      format.html {}
    end
  end
  
  def create
    @registration_form = params[:type] ? params[:type].constantize.new(params[:registration_form]) : RegistrationForm.new(params[:registration_form])
    respond_to do |format|
      if @registration_form.save
        flash[:notice] = "#{@registration_form.name} #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to edit_admin_registration_form_path(@registration_form) }
      else
        @role = Role.find_or_create_by_name('Admin')
        @users = @role.users.find(:all, :order => "last_name, first_name")
        format.html { render :action => :new }
      end
    end
  end

  def edit
    @role = Role.find_or_create_by_name('Admin')
    @users = @role.users.find(:all, :order => "last_name, first_name")
    @registration_form = RegistrationForm.find(params[:id])
    respond_to do |format|
      format.html {}
    end
  end

  def update
    @registration_form = RegistrationForm.find(params[:id])
    respond_to do |format|
      if @registration_form.update_attributes(params[:registration_form])
        flash[:notice] = "#{@registration_form.name} #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_registration_forms_path }
      else
        format.html { render :action => :edit }
      end
    end
  end

  def destroy
    @registration_form = RegistrationForm.find(params[:id])
    @registration_form.destroy
    Content.destroy_all(['resource_id = ? AND resource_type = ?', @registration_form.id, 'RegistrationForm'])
    flash[:notice] = "#{@registration_form.name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_registration_forms_path }
    end
  end
  
end
