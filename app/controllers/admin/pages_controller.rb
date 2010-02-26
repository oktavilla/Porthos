class Admin::PagesController < ApplicationController
  include Porthos::Admin
  before_filter :login_required

  def index
    
    @filters = Porthos::Filter.new(params[:filters] || {})

    @tags = Tag.on('Page').popular.find(:all, :limit => 30)
    @current_tags = params[:tags] || []
    @related_tags = @current_tags.any? ? Page.find_related_tags(@current_tags) : []
    
    
    @pages = unless @current_tags.any?
      Page.find_with_filter(@filters)
    else
      Page.find_tagged_with({:tags => params[:tags].join(' '), :order => 'created_at DESC'})
    end
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @page = Page.find(params[:id])
    if @page.node and @page.node.parent
      cookies[:last_opened_node] = { :value => @page.node.parent.id.to_s, :expires => 1.week.from_now }
    end
    @trail = if @node = @page.node
      (@node and @node.ancestors.any?) ? @node.ancestors.reverse << @node : [@node]
    else
      []
    end
  end
  
  def comments
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @page = Page.new(params[:page])
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def create
    @page = Page.new(params[:page])
    @node = Node.for_page(@page) unless @page.child?
    respond_to do |format|
      if @page.save
        if @node
          format.html { @node.save ? redirect_to(place_admin_node_path(@node)) : render(:action => :new) }
        else
          format.html { redirect_to admin_page_path(@page) }
        end
      else
        format.html { render :action => :new }
      end
    end
  end

  def edit
    @page = Page.find(params[:id])
    respond_to do |format|
      format.html
      format.js { render :action => 'edit', :layout => false }
    end
  end

  def update
    @page = Page.find(params[:id])
    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = t(:saved, :scope => [:app, :admin_pages])
        format.html { redirect_to params[:return_to] || admin_page_path(@page) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    respond_to do |format|
      flash[:notice] = "”#{@page.title}” #{t(:deleted, :scope => [:app, :admin_general])}"
      format.html { 
        redirect_to @page.child? ? url_for(:controller => @page.parent.class.to_s.tableize, :action => 'show', :id => @page.parent) : admin_nodes_path(:nodes => @page.node)
      }
    end
  end
  
  def toggle
    @page = Page.find(params[:id])
    @page.update_attributes(:active => !@page.active?)
    respond_to do |format|
      format.html { redirect_back_or_default(admin_page_path(@page)) }
    end
  end
  
  def sort
    params[:pages].each_with_index do |id, idx|
      Page.update(id, :position => idx+1)
    end
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end
  
  def publish
    self.class.send :include, Porthos::Public
    
    @page = Page.find(params[:id])
    @node = @page.node
    if @page.respond_to?(:pages)
      @pages = @page.pages.find_by_params(params, :logged_in => logged_in?)
    end
    
    @page.update_attributes({
      :rendered_body => render_to_string(:template => 'pages/show', :layout => false),
      :changes_published_at => Time.now
    })
    
    respond_to do |format|
      format.html { redirect_back_or_default admin_page_path(@page) }
    end
  end
  
end
