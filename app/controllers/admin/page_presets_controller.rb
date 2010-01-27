class Admin::PagePresetsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'content'
  
  def index
    @page_presets = PagePreset.find(:all)
  end
  
  def new
    @page_preset = PagePreset.new
  end
  
  def create
    @page_preset = PagePreset.new(params[:page_preset])
  
    respond_to do |format|
      if @page_preset.save
        flash[:notice] = "”#{@page_preset.name}” #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_page_presets_path }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def edit
    @page_preset = PagePreset.find(params[:id])
  end
  
  def update
    @page_preset = PagePreset.find(params[:id])
    respond_to do |format|
      if @page_preset.update_attributes(params[:page_preset])
        flash[:notice] = "”#{@page_preset.name}” #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to admin_page_presets_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @page_preset = PagePreset.find(params[:id])
    @page_preset.destroy
    respond_to do |format|
      format.html { redirect_to admin_page_presets_path }
    end
  end
  
end
