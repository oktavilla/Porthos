class FieldSet < ActiveRecord::Base
  validates_presence_of :title,
                        :handle
  validates_uniqueness_of :title,
                          :handle
  
  has_many :fields,
           :order => 'fields.position',
           :dependent => :destroy
           
  has_many :pages, :dependent => :destroy, :order => 'published_on DESC, id DESC' do
    def within(year, month, day)
      from, to = Time.delta(year, month, day)
      published_within from, to
    end

    def latest(options = {})
      options = {
        :include_restricted => false,
        :page => 1,
        :per_page => 10,
        :order => 'published_on DESC, id DESC'
      }.merge(options)
      active.include_restricted(options[:include_restricted]).paginate({
        :page => options[:page],
        :per_page => options[:per_page],
        :order => options[:order]
      })
    end

    def by_date(options = {})
      options = {
        :include_restricted => false,
        :page => 1,
        :per_page => 10,
        :order => 'published_on DESC, id DESC'
      }.merge(options)
      from, to = Time.delta(options[:year], options[:month], options[:day])
      active.published.include_restricted(options[:include_restricted]).published_within(from, to).paginate({
        :page => options[:page],
        :per_page => options[:per_page],
        :order => options[:order]
      })
    end

    def tags
      sql = "select distinct tags.*, count(taggings.taggable_id) as count
      from taggings
      left join tags on tags.id = taggings.tag_id
      where taggings.taggable_type = '#{proxy_owner.class.base_class}'
      and taggings.taggable_id in(select pages.id from pages where pages.parent_id = #{ proxy_owner.id })
      group by taggings.tag_id"
      Tag.find_by_sql(sql)
    end

    def published_within(from, to)
      find(:all, :conditions => ["active = 1 AND published_on BETWEEN ? AND ? AND published_on <= CURRENT_DATE", from.to_s(:db), to.to_s(:db)])
    end

    def find_by_params(params, options = {})
      if params[:tags]
        return find_with_tags(params[:tags], {
          :include_restricted => options[:logged_in],
          :page     => params[:page],
          :per_page => params[:per_page] || 10
        })
      end
      if params[:year]
        conditions = {
          :year   => params[:year],
          :month  => params[:month],
          :day    => params[:day],
          :page   => params[:page],
          :include_restricted => true
        }
        active.published.by_date(conditions)
      else
        active.published.latest({
          :page => params[:page],
          :include_restricted => true
        })
      end
    end

   def find_with_tags(tags, options)
     active.include_restricted(options[:include_restricted]).published.find_tagged_with({
       :tags => tags,
       :order => 'created_at DESC, id DESC'
     }).paginate(:page => options[:page], :per_page => options[:per_page])
   end
  end

  def dates_with_children(options = {})
   options = { :year => Time.now.year }.merge options.symbolize_keys
   years = connection.select_values("select distinct year(published_on) as year from pages where parent_id = #{ self.id } and parent_type = 'Page' and published_on <= now() and active = 1 order by year desc")
   years.collect do |year|
     months = connection.select_values("select distinct month(published_on) as month, year(published_on) as year from pages where year(published_on) = #{ year } and parent_id = #{ self.id } and parent_type = 'Page' and published_on <= now() and active = 1 order by month desc")
     [year, months.collect { |month| Time.mktime(year, month) } ]
   end
  end

  def slug_for_child(child)
   [node.slug, child.published_on.strftime('%Y/%m/%d'), child.slug].join('/')
  end

  before_validation :parameterize_handle


  def template
    @template ||= template_name.present? ? PageTemplate.new(template_name) : PageTemplate.default
  end
  
protected

  def parameterize_handle
    self.handle = handle.parameterize
  end

end