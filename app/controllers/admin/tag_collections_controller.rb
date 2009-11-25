class Admin::TagCollectionsController < ApplicationController
  include Porthos::Admin
  
  before_filter :login_required
  before_filter :find_page_collection
  
  layout 'content'
  
  def new
    @tag_collection = @page.tag_collections.build
    respond_to do |format|
      format.html
    end
  end
  
  def create
    @tag_collection = @page.tag_collections.build(params[:tag_collection])
    respond_to do |format|
      if @tag_collection.save
        format.html { redirect_to admin_page_collection_tag_collections_path(@page) }
      else
        format.html { render :action => 'new' }
      end
    end
  end
  
  def edit
    @tag_collection = @page.tag_collections.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @tag_collection = @page.tag_collections.find(params[:id])
    respond_to do |format|
      if @tag_collection.save
        format.html { redirect_to admin_page_path(@page) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @tag_collection = @page.tag_collections.find(params[:id])
    @tag_collection.destroy
    respond_to do |format|
      format.html
    end
  end
  
protected

  def find_page_collection
    @page = PageCollection.find(params[:page_collection_id])
  end

end