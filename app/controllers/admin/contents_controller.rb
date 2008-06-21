class Admin::ContentsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required, :find_page
  skip_after_filter :remember_uri

  layout 'admin'
  
  def show
    @content = Content.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render :json => @content.to_json }
    end
  end
  
  def new
    @content = @page.contents.build(params[:content])
    @content.resource = @content.resource_type.constantize.new(params[:resource])
    respond_to do |format|
      format.html { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/new" }
      format.js { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/new", :layout => false }
    end
  end
  
  def edit
    @content  = Content.find(params[:id])
    respond_to do |format|
      format.html { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/edit" }
      format.js   { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/edit", :layout => false }
    end
  end
  
  def update
    @content = Content.find(params[:id])
    @saved = if params[@content.resource_type.underscore]
      @content.resource.update_attributes(params[@content.resource_type.underscore])
    elsif params[:content]
      @content.update_attributes(params[:content])
    else
      false
    end
    respond_to do |format|
      if @saved
        format.html { redirect_to admin_page_path(:id => @page.id, :anchor => "content_#{@content.id}") }
      else
        format.html { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/edit" }
      end
    end
  end

  def create
    Content.transaction do
      @content = @page.contents.build({ :column_position => 1, :active => 0 }.stringify_keys.merge(params[:content]))
      if @content.resource_id.blank?
        @resource = @content.resource_type.constantize.new(params[@content.resource_type.underscore])
        @resource.parent = @content if @resource.respond_to?(:parent)
        @resource.save!
        @content.resource = @resource
      end
      @content.save!
      if params[:collection]
        @collection = ContentCollection.create((params[:content] || {}).merge(:page_id => @page.id) )
        @collection.contents << @content
      end
    end
    respond_to do |format|
      format.html { redirect_to admin_page_path(:id => @page.id, :anchor => "content_#{@content.id}") }
    end
  rescue ActiveRecord::RecordInvalid
    @content.valid?
    respond_to do |format|
      format.html { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/new" }
      format.js { render :template => "/admin/contents/#{@content.resource_type.underscore.pluralize}/new", :layout => false }
    end
  end

  def destroy
    @content = Content.find(params[:id])
    @content.destroy
    flash[:notice] = "Sidinnehåll borttaget" unless @content.resource and @content.resource_type == 'Textfield' and @content.resource.body.blank?
    respond_to do |format|
      format.html { redirect_to admin_page_path(@page) }
    end
  end

  def sort
    params[:contents].each_with_index do |id, index|
      if params[:column_position]
        @page.contents.update(id, :position => index+1, :column_position => params[:column_position])
      else
        Content.update(id, :position => index+1)
      end
    end if params[:contents]
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  def toggle
    @content = Content.find(params[:id])
    @content.update_attributes(:active => !@content.active)
    respond_to do |format|
      format.html { redirect_to admin_page_path(:id => @page, :anchor => "content_#{@content.id}") }
      format.js
    end
  end

private
  def find_page
    @page = Page.find(params[:page_id])
  end
end
