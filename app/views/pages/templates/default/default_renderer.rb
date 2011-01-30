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

  class Categories < Porthos::PageRenderer
    def categories
      return @categories if @categories
      @categories = Tag.on('Page').namespaced_to(@field_set.handle).all
      @categories
    end
    register_methods :categories
  end

  def self.categories(field_set, params)
    DefaultRenderer::Categories.new(field_set, params)
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

  def self.category(field_set, params)
    DefaultRenderer::Category.new(field_set, params)
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

  class TaggedWith < Porthos::PageRenderer

    def categories
      @categories ||= Tag.on('Page').namespaced_to(@field_set.handle).all
    end

    def category
      nil
    end

    def pages
      return @pages if @pages
      @pages = Page.find_tagged_with(:tags => selected_tag_names, :conditions => ['pages.field_set_id = ?', @field_set.id]).tap do |pages|
        pages.each { |p| p.send :cache_custom_attributes }
      end
    end

    def tags
      @tags ||= @field_set.tags_for_pages
    end

    def selected_tags
      if @selected_tags
        @selected_tags
      else
        @selected_tags = if params[:tags].present? && params[:tags].any?
          params[:tags].collect{|t| Tag.find_by_name(t) }.compact
        else
          []
        end
      end
    end

    def selected_tag_names
      @selected_tag_names if @selected_tag_names.present?
      @selected_tag_names = if selected_tags && selected_tags.any?
        selected_tags.collect{|t| t.name }
      else
        []
      end
    end

    register_methods :categories, :category, :pages, :tags, :selected_tags, :selected_tag_names
  end

  def self.tagged_with(field_set, params)
    DefaultRenderer::TaggedWith.new(field_set, params)
  end
end
