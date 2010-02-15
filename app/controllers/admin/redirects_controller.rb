class Admin::RedirectsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'content'
  
  def index
    @redirects = Redirect.find(:all, :order => 'path')
    respond_to do |format|
      format.html {}
    end
  end
  
  def new
    @redirect = Redirect.new
    respond_to do |format|
      format.html {}
    end
  end
  
  def create
    @redirect = Redirect.new(params[:redirect])
    respond_to do |format|
      if @redirect.save
        flash[:notice] = "Vidarebefordring sparad"
        format.html { redirect_to admin_redirects_path }
      else
        format.html { render :action => :new }
      end
    end
  end
  
  def edit
    @redirect = Redirect.find(params[:id])
    respond_to do |format|
      format.html {}
    end
  end
  
  def update
    @redirect = Redirect.find(params[:id])
    respond_to do |format|
      if @redirect.update_attributes(params[:redirect])
        flash[:notice] = "Vidarebefordring sparad"
        format.html { redirect_to admin_redirects_path }
      else
        format.html { render :action => :edit }
      end
    end
  end
  
  def destroy
    @redirect = Redirect.find(params[:id])
    @redirect.destroy
    respond_to do |format|
      flash[:notice] = "Vidarebefordring raderad"
      format.html { redirect_to admin_redirects_path }
    end
  end
end