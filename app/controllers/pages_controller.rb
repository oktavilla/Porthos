class PagesController < ApplicationController
  include Porthos::Public
  before_filter :require_node

  layout 'public'

  def show
    # If the page belongs to a date sorted structure we need to find by the slug, otherwise the id should be registred in routes
    @page = if params[:id]
      (current_user != :false and current_user.admin?) ? Page.find(params[:id]) : Page.active.published.find(params[:id])
    elsif params[:page_slug]
      page = @node.resource.pages.active.find_by_slug("#{params[:page_slug]}") || (raise ActiveRecord::RecordNotFound)
      login_required if page.restricted and not logged_in?
      (page and (not page.parent_type.blank? and page.parent.calendar?) or page.published?) ? page : (raise ActiveRecord::RecordNotFound)
    else 
      raise ActiveRecord::RecordNotFound
    end
    if @page.is_a?(PageCollection)
      unless params[:tags]
        @pages = if params[:year]
          if @page.calendar?
            @page.pages.active.by_date({
              :year   => params[:year],
              :month  => params[:month],
              :day    => params[:day],
              :page   => params[:page],
              :include_restricted => true
            })
          else
            @page.pages.active.published.by_date({
              :year   => params[:year],
              :month  => params[:month],
              :day    => params[:day],
              :page   => params[:page],
              :include_restricted => true
            })
          end
        else
          if @page.calendar?
            @page.pages.active.latest({
              :page => params[:page],
              :include_restricted => true
            })
          else
            @page.pages.active.published.latest({
              :page => params[:page],
              :include_restricted => true
            })
          end
        end
      else
        @pages = @page.pages.active.include_restricted(logged_in?).published.find_tagged_with({
          :tags => params[:tags].join(Tag.delimiter),
          :order => 'created_at DESC'
        }).paginate(:page => params[:page], :per_page => 10)
      end
    end
    # pre cache content resources
    resource_types = @page.contents.active.collect(&:resource_type).uniq
    resource_types.each do |resource_type|
      resource_type.constantize.find_all_by_id(@page.contents.active.select { |c| c.resource_type == resource_type }.collect(&:resource_id).uniq)
    end
    
    respond_to do |format|
      format.html {}
      format.rss { render :layout => false } if @page.is_a?(PageCollection)
    end
  end
  
  # POST
  def comment
    @page    = Page.find(params[:id])
    @comment = @page.comments.new(params[:comment])
    @comment.ip_address = request.remote_ip
    @comment.env = request.env
    respond_to do |format|
      if @comment.save
        if @comment.spam
          flash[:notice] = 'Din kommentar har sparats'
        else
          flash[:notice] = 'Din kommentar har sparats och publicerats'
        end  
        format.html { redirect_to (params[:return_to] || "/#{@node.slug}#comment_#{@comment.id}") }
      else
        format.html { render :action => 'show' }
      end
    end
  end

end
