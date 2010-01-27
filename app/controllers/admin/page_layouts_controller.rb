class Admin::PageLayoutsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'content'
  
  def index
    @page_layouts = PageLayout.find(:all)
  end
  
  def new
    @page_layout = PageLayout.new
  end
  
  def create
    @page_layout = PageLayout.new(params[:page_layout])
    respond_to do |format|
      if @page_layout.save
        flash[:notice] = "”#{@page_layout.name}” #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_page_layouts_path }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @page_layout = PageLayout.find(params[:id])
    @default_textfields = Textfield.find_all_by_shared(true)
    @default_modules    = ContentModule.find(:all)
  end
  
  def update
    @page_layout = PageLayout.find(params[:id])
    respond_to do |format|
      if @page_layout.update_attributes(params[:page_layout])
        flash[:notice] = "”#{@page_layout.name}” #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_page_layouts_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @page_layout = PageLayout.find(params[:id])
  end
  
end
