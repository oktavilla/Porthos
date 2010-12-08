require 'porthos/page_renderer'
module DefaultRenderer

  class Index < Porthos::PageRenderer

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

  def self.index(field_set, params)
    DefaultRenderer::Index.new(field_set, params)
  end

  class Show < Porthos::PageRenderer
    attr_accessor :page

    def initialize(field_set, page, params)
      @page = page
      super(field_set, params)
    end

    def layout_class
      @page.layout_class
    end

  end

  def self.show(field_set, page, params)
    DefaultRenderer::Show.new(field_set, page, params)
  end

end
