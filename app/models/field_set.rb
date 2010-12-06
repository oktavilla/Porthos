class FieldSet < ActiveRecord::Base
  validates_presence_of :title,
                        :page_label,
                        :handle

  validates_uniqueness_of :title,
                          :handle

  has_many :fields,
           :order => 'fields.position',
           :dependent => :destroy

  has_many :pages,
           :dependent => :destroy,
           :include => [:custom_attributes, :custom_associations]

  has_one :node,
          :conditions => { :controller => 'pages', 'action' => 'index' }

  acts_as_list

  def dates_with_children(options = {})
    options = { :year => Time.now.year }.merge(options.symbolize_keys)
    years = connection.select_values("select distinct year(published_on) as year from pages where field_set_id = #{ self.id } and published_on <= now() and active = 1 order by year desc")
    years.collect do |year|
      months = connection.select_values("select distinct month(published_on) as month, year(published_on) as year from pages where year(published_on) = #{ year } and field_set_id = #{ self.id } and published_on <= now() and active = 1 order by month desc")
      [year, months.collect { |month| Time.mktime(year, month) } ]
    end
  end

  before_validation :parameterize_handle

  def template
    @template ||= template_name.present? ? PageTemplate.new(template_name) : PageTemplate.default
  end

  def renderer(action, *args)
    "#{template.name.camelize}Renderer".constantize.send(action, self, *args)
  end

protected

  def parameterize_handle
    self.handle = handle.parameterize
  end

end