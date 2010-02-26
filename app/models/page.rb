class Page < ActiveRecord::Base
  
  validates_presence_of :title, :page_layout_id

  belongs_to  :parent,  :polymorphic => true
  has_one     :node,    :as => :resource
  has_many(:contents, {
    :as         => :context,
    :order      => :position,
    :conditions => ["contents.parent_id IS NULL"],
    :dependent  => :destroy
  })
  
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'

  belongs_to  :page_layout
  belongs_to(:default_child_layout, {
    :foreign_key => 'default_child_layout_id',
    :class_name  => 'PageLayout'
  })
  has_many :comments, :as => :commentable, :order => 'comments.created_at'
  
  named_scope :published, :conditions => ["published_on <= ?", Time.now.at_midnight + 1.day]
  named_scope :published_within, lambda { |from, to| {
    :conditions => [
      "published_on BETWEEN ? AND ?",
      from.to_s(:db),
      to.to_s(:db)
    ] 
  }}

  named_scope :active,   :conditions => ["active = ?", true]
  named_scope :inactive, :conditions => ["active = ?", false]
  named_scope :include_restricted, lambda { |restricted| {
    :conditions => [
      'restricted = ? or restricted = 0',
      restricted
    ]
  }}
  named_scope :with_unpublished_changes, :conditions => ["changed_at > changes_published_at AND rendered_body IS NOT NULL"]
  
  named_scope :created_latest, :order => 'created_at DESC'
  named_scope :updated_latest, :conditions => 'changed_at > created_at', :order => 'changed_at DESC'

  named_scope :filter_created_by, lambda { |user_id|
    { :conditions => ["created_by_id = ?", user_id] }
  }
  named_scope :filter_updated_by, lambda { |user_id|
    { :conditions => ["updated_by_id = ?", user_id] }
  }
  named_scope :filter_with_parent, lambda { |parent_id|
    { :conditions => ["parent_id = ? ", parent_id] }
  }

  before_validation_on_create :set_default_layout, :set_inactive

  before_create :set_published_on
  before_create :set_created_by
  before_save   :set_layout_attributes, :generate_slug
  before_update :set_updated_by
  after_create  :insert_default_contents

  acts_as_list :scope => 'parent_id = \'#{parent_id}\' and parent_type = \'#{parent_type}\''
  acts_as_taggable
  acts_as_filterable  
  
  #acts_as_defensio_article :fields => { :title => :title, :content => :body }
  
  is_indexed({
    :fields => ['title', 'description', 'slug', 'type'],
    :concatenate => [{
      :class_name => 'Textfield', :field => 'body', :as => 'body', 
      :association_sql => "LEFT OUTER JOIN contents ON (pages.id = contents.page_id AND contents.active = 1) LEFT OUTER JOIN textfields ON (textfields.id = contents.resource_id AND contents.resource_type = 'Textfield')"
    }],
    :include => [{
      :association_name => 'node', :field => 'status', :as => 'node_status', 
      :association_sql => "LEFT OUTER JOIN nodes AS node ON (pages.id = node.resource_id AND node.resource_type = 'Page')"
    }], :conditions => "pages.active = 1 AND node.status != -1"
  })
  
  
  attr_accessor :preset_id
  
  def body
    contents.collect {|c| c.resource.body if c.resource_type == 'Textfield' }.join
  end
  
  def published?
    published_on <= Time.now.end_of_day
  end

  def unpublished_changes?
    if !changes_published_at.nil? && !changed_at.nil?
      changed_at > changes_published_at
    else
      true
    end
  end

  def child?
    not parent_type.blank? and not parent_id.blank?
  end

  def part_of_collection?
    child? and parent_type == 'Page'
  end

  class << self
    def available_filters
      self.scopes.keys.map { |m| m.to_s }.select do |m|
        m =~ /^filter_/
      end.map { |m| m[7..-1].to_sym }
    end
  end

private

  def set_inactive
    self.active = !self.child?
    true
  end

  def generate_slug
    self.slug = title.to_url
  end

  def set_published_on
    self.published_on = Time.now.at_midnight if published_on.blank?
  end
  
  def set_layout_attributes    
    contents.update_all("column_position = #{page_layout.columns}", "column_position > #{page_layout.columns}") unless column_count == page_layout.columns or column_count.blank?
    self.layout_class = page_layout.css_id
    self.column_count = page_layout.columns
    self.main_content_column = page_layout.main_content_column
  end
  
  def set_default_layout
    self.page_layout = parent.default_child_layout if child? and parent.respond_to?(:default_child_layout)
  end
  
  def insert_default_contents
    self.page_layout.default_contents.each do |d|
      c = Content.new
      c.resource_type, c.resource_id, c.column_position = d.resource_type, d.resource_id, d.column_position
      self.contents << c
    end if self.page_layout and self.page_layout.default_contents.any?
  end
  
  def set_created_by
    self.created_by = User.current
  end
  
  def set_updated_by
    self.updated_by = User.current
  end
  
end
