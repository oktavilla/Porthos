class PagesController < ApplicationController
  include Porthos::Public
  before_filter :require_node

  before_filter :only => :preview do |c|
    user = c.send :current_user
    raise ActiveRecord::RecordNotFound if user == :false or !user.admin?
  end

  layout 'public'

  def index
    @field_set = @node.field_set
    scope = @field_set.pages.
                       active.
                       published.
                       include_restricted(logged_in?)
    @pages = unless params[:tags]
      scope = scope.published_within(*Time.delta(params[:year], params[:month], params[:day])) if params[:year]
      scope.paginate(:page => (params[:page] || 1), :per_page => (params[:per_page] || 25))
    else
      scope.find_tagged_with(:tags => params[:tags])
    end
    
    respond_to do |format|
      format.html { render :template => @field_set.template.views.index }
      format.rss  { render :template => @field_set.template.views.index, :layout => false }
    end
  end

  def show
    # If the page belongs to a date sorted structure we need to find by the slug,
    # otherwise the id should be registred in routes
    @page = if params[:id]
      Page.active.published.find(params[:id])
    elsif params[:page_slug]
      page = @node.resource.pages.active.find_by_slug(params[:page_slug]) or raise ActiveRecord::RecordNotFound
      (page and (not page.parent_type.blank? and page.parent.calendar?) or page.published?) ? page : (raise ActiveRecord::RecordNotFound)
    end

    login_required if @page.restricted?

    respond_to do |format|
      unless @page.rendered_body.blank?
        format.html { render :inline => @page.rendered_body, :layout => true }
      else
        @full_render = true
        format.html { render :template => @page.field_set.template.views.show }
      end
    end
  end
  
  def preview
    @page = Page.find(params[:id])
    @full_render = true
    respond_to do |format|
      format.html { render :template => @page.field_set.template.views.show }
    end
  end
  
  def search
    @field_set = @node.field_set
    search_query = params[:query] if params[:query].present?
    if search_query.present? or params[:filters].any?
      field_set_id = @field_set.id
      @search = Page.search do
        keywords search_query
        if params[:filters] && params[:filters].any?
          dynamic :custom_attributes do
            params[:filters].each do |key, value|
              with(key.to_sym).starting_with(value)
            end
          end
        end
        with(:is_active, true)
        with(:field_set_id, field_set_id)
        with(:published_on).less_than Time.now
      end
      @query = params[:query]
      @filters = params[:filters]
    end
    respond_to do |format|
      format.html { render :template => @field_set.template.views.search }
    end
  end
  
  # POST
  def comment
    @page    = Page.find(params[:id])
    @comment = @page.comments.new(params[:comment])
    @comment.ip_address, @comment.env = request.remote_ip, request.env
    respond_to do |format|
      if @comment.save
        flash[:notice] = @comment.spam ? t(:saved, :scope => [:app, :admin_comments]) : t(:published, :scope => [:app, :admin_comments])
        format.html { redirect_to (params[:return_to] || "/#{@node.slug}#comment_#{@comment.id}") }
      else
        format.html { render :action => 'show' }
      end
    end
  end

end
