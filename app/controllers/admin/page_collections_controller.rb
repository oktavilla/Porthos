class Admin::PageCollectionsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  
  def show
    @page = PageCollection.find(params[:id])
    per_page = params[:per_page] || 12
    if params[:year]
      from, to = Time.delta(params[:year] || Time.now.year, params[:month], params[:day])
      to += 1.month if @page.calendar?
      @pages = @page.pages.published_within(from, to).paginate(:page => params[:page], :per_page => per_page, :order => 'published_on DESC')
    else
      @pages = @page.pages.paginate(:page => params[:page], :per_page => per_page, :order => 'published_on DESC')
    end
    @inactive_pages = @page.pages.inactive.find(:all, :order => 'published_on DESC')
    respond_to do |format|
      format.html {}
    end
  end

  def new
    @page = PageCollection.new
    respond_to do |format|
      format.html {}
      format.js { render :layout => false }
    end
  end

  def create
    @page = PageCollection.new(params[:page_collection])
    @node = Node.for_page(@page) unless @page.child?
    respond_to do |format|
      if @page.save
        if @node
          if @node.save
            format.html { redirect_to place_admin_node_path(@node) }
          else
            format.html { render :action => :new }
          end
        else
          format.html { redirect_to admin_page_path(@page) }
        end
      else
        format.html { render :action => :new }
      end
    end
  end

end
