# == Schema Information
# Schema version: 76
#
# Table name: pages
#
#  id                      :integer(11)   not null, primary key
#  title                   :string(255)   
#  description             :text          
#  page_layout_id          :integer(11)   
#  layout_class            :string(255)   
#  column_count            :integer(11)   
#  published_on            :datetime      
#  created_at              :datetime      
#  updated_at              :datetime      
#  slug                    :string(255)   
#  type                    :string(255)   
#  position                :integer(11)   
#  parent_id               :integer(11)   
#  parent_type             :string(255)   
#  default_child_layout_id :integer(11)   
#

class PageCollection < Page

  has_many :pages, :as => :parent, :dependent => :destroy, :order => 'published_on DESC' do
    def within(year, month, day)
      from, to = Time.delta(year, month, day)
      published_within from, to
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
      find(:all, :conditions => ["active = 1 AND published_on BETWEEN ? AND ? #{'AND published_on <= CURRENT_DATE' unless proxy_owner.calendar?}", from.to_s(:db), to.to_s(:db)])
    end
  end

  def dates_with_children(options = {})
    options = { :year => Time.now.year }.merge options.symbolize_keys
    if self.calendar?
      years = connection.select_values("select distinct year(published_on) as year from pages where parent_id = #{ self.id } and parent_type = 'Page' and active = 1 order by year desc")
    else
      years = connection.select_values("select distinct year(published_on) as year from pages where parent_id = #{ self.id } and parent_type = 'Page' and published_on <= now() and active = 1 order by year desc")
    end
    years.collect do |year|
      if self.calendar?
        months = connection.select_values("select distinct month(published_on) as month, year(published_on) as year from pages where year(published_on) = #{ year } and parent_id = #{ self.id } and parent_type = 'Page' and active = 1 order by month desc")
      else
        months = connection.select_values("select distinct month(published_on) as month, year(published_on) as year from pages where year(published_on) = #{ year } and parent_id = #{ self.id } and parent_type = 'Page' and published_on <= now() and active = 1 order by month desc")
      end
      [year, months.collect { |month| Time.mktime(year, month) } ]
    end
  end

  class << self
    
    def can_be_created_by?(user)
      user.has_role?('SiteAdmin')
    end

  end

end
