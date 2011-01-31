require 'porthos/page_renderer'
module DefaultRenderer

  class Index < Porthos::PageRenderer

    def layout_class
      "#{@field_set.handle}-index"
    end

    def title
      @field_set.title
    end

    def page_id
      @field_set.handle
    end

    def pages
      return @pages if @pages
      scope = @field_set.pages.
                         published
      if params[:year]
        scope = scope.published_within(*Time.delta(params[:year], params[:month], params[:day]))
      end
      @pages = scope.paginate({
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 25),
        :order => 'pages.published_on DESC, pages.id DESC'
      }).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
    register_methods :pages

  end

  class Categories < Porthos::PageRenderer
    def categories
      return @categories if @categories
      @categories = Tag.on('Page').namespaced_to(@field_set.handle).all
      @categories
    end
    register_methods :categories
  end

  class Category < Porthos::PageRenderer
    def category
      return @category if @category
      @category = Tag.find_by_name(params[:id]) or raise ActiveRecord::RecordNotFound
    end
    register_methods :category

    def pages
      return @pages if @pages
      @pages = Page.find_tagged_with(:tags => category.name, :namespace => @field_set.handle).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end
  end

  class Show < Porthos::PageRenderer
    self.required_objects = [:field_set, :page]

    def layout_class
      @page.layout_class
    end

    def title
      @page.title
    end

  protected

    def after_initialize
      @page.send :cache_custom_attributes
    end

  end
end
