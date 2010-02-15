class Admin::AssetsController < ApplicationController
  include Porthos::Admin
  
  before_filter :login_required
  skip_before_filter :clear_content_context
  before_filter :set_cotent_context, :only => :index
  skip_before_filter :remember_uri, :only => [:index, :show, :create, :search]

  layout 'admin'
  
  protect_from_forgery :only => :create
  
  # GET /assets
  # GET /assets.xml
  def index
    @type = params[:type] ? params[:type].classify.constantize : Asset
    @tags = Tag.on('Asset').popular.find(:all, :limit => 30)
    @current_tags = params[:tags] || []
    @related_tags = @current_tags.any? ? @type.find_related_tags(@current_tags) : []
    @assets = unless @current_tags.any?
      @per_page = params[:per_page] || 20
      @type.public.paginate(:page => params[:page], :per_page => @per_page.to_i, :order => 'created_at DESC', :conditions => 'incomplete = 0')
    else
      @type.public.find_tagged_with({:tags => params[:tags].join(','), :order => 'created_at DESC'})
    end
    @asset = Asset.new
    respond_to do |format|
      format.html
      format.xml { render :xml => @assets.to_xml }
      format.js { render :action => 'index', :layout => false }
    end
  end

  def search
    @type = params[:type] ? params[:type] : 'Asset'
    @tags = Tag.on('Asset').popular.find(:all, :limit => 30)
    unless params[:query].blank?
      @query = params[:query] 
      @page = params[:page] || 1
      per_page = params[:per_page] ? params[:per_page].to_i : 45
      @search = Ultrasphinx::Search.new(:query => "#{@query}", :class_names => ['Asset','ImageAsset','MovieAsset'], :page => @page, :per_page => per_page)
      @search.run
      @assets = @search.results
      respond_to do |format|
        format.html do
          @current_tags = params[:tags] || []
          @related_tags = @current_tags.any? ? @type.find_related_tags(@current_tags) : []
        end
        format.js { render :action => 'search', :layout => false }
        format.xml { render :xml => @assets.to_xml }
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_assets_path }
        format.js { render :action => 'search', :layout => false }
      end
    end
  end

  def show
    @asset = Asset.find(params[:id])
    respond_to do |format|
      format.js { render :json => @asset.to_json(:methods => [:type, :thumbnail]) }
    end
  end

  # GET /assets/new
  def new
    @asset = Asset.new
    respond_to do |format|
      format.html
    end
  end

  # GET /assets/1;edit
  def edit
    @asset = Asset.find_by_file_name(params[:id])
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  # POST /assets
  # POST /assets.xml
  def create
    if params[:asset]
      @assets = [Asset.from_upload(params[:asset].merge({:created_by => current_user,  :incomplete => true }))]
    else
      @assets = params[:files].collect do |upload|
        Asset.from_upload(:file => upload, :created_by => current_user, :incomplete => true) unless upload.blank?
      end.compact
    end
    @not_saved = @assets.collect{ |a| a.save }.include? false
    respond_to do |format|
      unless @not_saved
        flash[:notice] = t(:saved, :scope => [:app, :admin_assets])
        format.html { redirect_to incomplete_admin_assets_url }
        format.xml  { head :created, :location => asset_url(@asset) }
        format.json do
          # empty file object because it messes up the json parser
          @assets.first.file = nil
          render :text => @assets.collect{ |asset| asset.attributes_for_js }.to_json, :layout => false, :status => 200
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @asset.errors.to_xml }
      end
    end
  end
  
  def incomplete
    @assets = Asset.find(:all, :conditions => ['incomplete = 1 AND created_by = ?', current_user.id])
  end

  def update_multiple
    params[:assets].each do |asset|
      save_asset = Asset.find(asset[0])
      save_asset.incomplete = 0
      save_asset.update_attributes(asset[1])
    end
    flash[:notice] = t(:saved, :scope => [:app, :admin_assets])
    respond_to do |format|
      format.html { redirect_to admin_assets_url }
      format.xml  { head :ok }
    end
  end

  # PUT /assets/1
  # PUT /assets/1.xml
  def update
    @asset = Asset.find_by_file_name(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        flash[:notice] = "#{@asset.full_name} #{t(:saved, :scope => [:app, :admin_general])}"
        format.html { redirect_to previous_view_path(admin_assets_url) }
        format.js   { render :layout => false }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js   { render :layout => false }
        format.xml  { render :xml => @assset.errors.to_xml }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @asset = Asset.find_by_file_name(params[:id])
    @asset.destroy
    flash[:notice] = "#{@asset.full_name} #{t(:deleted, :scope => [:app, :admin_general])}"
    respond_to do |format|
      format.html { redirect_to admin_assets_path }
      format.xml  { head :ok }
    end
  end

protected

  def set_cotent_context
    @content = session[:content] ||= params[:content]
  end

end
