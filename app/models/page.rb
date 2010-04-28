class Page < ActiveRecord::Base
  
  validates_presence_of :title,
                        :field_set_id,
                        :page_layout_id

  belongs_to :parent,
             :polymorphic => true
  
  has_one :node,
          :as => :resource
  
  has_many :contents,
           :as => :context,
           :order => :position,
           :conditions => ["contents.parent_id IS NULL"],
           :dependent  => :destroy

  belongs_to :field_set
  has_many :fields,
           :through => :field_set
  
  has_many :custom_attributes,
           :as => :context,
           :dependent => :destroy

  has_many :custom_associations,
           :as => :context,
           :dependent => :destroy

  has_many :association_targets,
           :through => :custom_associations

  belongs_to :created_by,
             :class_name => 'User'
  
  belongs_to :updated_by,
             :class_name => 'User'

  belongs_to  :page_layout
  belongs_to  :default_child_layout,
              :foreign_key => 'default_child_layout_id',
              :class_name  => 'PageLayout'

  has_many :comments,
           :as => :commentable,
           :order => 'comments.created_at'
  
  named_scope :published,
              :conditions => ["published_on <= ?", Time.now.at_midnight + 1.day]
              
  named_scope :published_within, lambda { |from, to| {
    :conditions => [
      "published_on BETWEEN ? AND ?",
      from.to_s(:db),
      to.to_s(:db)
    ] 
  }}

  named_scope :active,
              :conditions => ["active = ?", true]
  named_scope :inactive,
              :conditions => ["active = ?", false]
  named_scope :include_restricted, lambda { |restricted| {
    :conditions => [
      'restricted = ? or restricted = 0',
      restricted
    ]
  }}

  named_scope :created_latest, 
              :order => 'created_at DESC'
  named_scope :updated_latest, 
              :conditions => 'changed_at > created_at', 
              :order => 'changed_at DESC'

  named_scope :filter_created_by, lambda { |user_id| {
    :conditions => ["created_by_id = ?", user_id]
  }}
  named_scope :filter_updated_by, lambda { |user_id| {
    :conditions => ["updated_by_id = ?", user_id]
  }}
  named_scope :filter_with_parent, lambda { |parent_id|
    !parent_id.blank? ? { :conditions => ["parent_id = ? ", parent_id] } : { :conditions => ["parent_id IS NULL"] }
  }
  named_scope :filter_order_by, lambda { |order| {
    :order => order
  }}
  named_scope :filter_active, lambda { |active| {
    :conditions => ["active = ?", active]
  }}
  named_scope :filter_with_unpublished_changes,
              :conditions => ["changed_at > changes_published_at AND rendered_body IS NOT NULL"]
  
  before_validation_on_create :set_default_layout, :set_inactive

  before_create :set_published_on
  before_create :set_created_by
  before_save   :set_layout_attributes,
                :generate_slug
  before_update :set_updated_by
  after_create  :insert_default_contents

  acts_as_list :scope => 'parent_id = \'#{parent_id}\' and parent_type = \'#{parent_type}\''
  acts_as_taggable
  acts_as_filterable  
  
  #acts_as_defensio_article :fields => { :title => :title, :content => :body }
  
  is_indexed({
    :fields => ['title', 'description', 'rendered_body'],
    :concatenate => [{
      :class_name => 'Tag', :field => 'name', :as => 'tags', 
      :association_sql => "LEFT OUTER JOIN taggings ON (pages.id = taggings.taggable_id AND taggings.taggable_type = 'Page') LEFT OUTER JOIN tags ON (tags.id = taggings.tag_id)"
    }],
    :delta => { :field => 'changed_at' }
  })
    
  def published?
    published_on <= Time.now.end_of_day
  end

  def unpublished_changes?
    if !changes_published_at.nil? && !changed_at.nil?
      changed_at > changes_published_at
    else
      !changed_at.nil?
    end
  end

  def child?
    not parent_type.blank? and not parent_id.blank?
  end

  def part_of_collection?
    child? and parent_type == 'Page'
  end
  
  def full_slug
    if child?
      if parent.respond_to?(:slug_for_child)
        parent.slug_for_child(self)
      elsif parent.respond_to?(:node)
        parent.node.slug+'/'+self.slug
      elsif parent.respond_to?(:slug)
        parent.slug+'/'+self.slug
      end
    else
      if node
        node.slug
      else
        slug
      end
    end
  end

  def custom_value_for(field)
    unless field.data_type == CustomAssociation
      if custom_attribute = custom_attribute_for_field(field.id)
        custom_attribute.value 
      end
    else
      custom_associations.with_field(field.id).all
    end
  end

  def custom_attribute_for_field(field_id)
    custom_attributes.detect { |cd| cd.field_id == field_id.to_i }
  end

  def custom_association_for_field(field_id)
    custom_associations.detect { |ca| ca.field_id == field_id.to_i }
  end

  def custom_fields=(custom_fields)
    custom_fields.each do |key, value|
      field = Field.find(key)
      unless field.data_type == CustomAssociation
        if custom_attribute = custom_attribute_for_field(field.id)
          custom_attribute.update_attributes(:value => value)
        else
          field.data_type.create({
            :value   => value,
            :field   => field,
            :handle  => field.handle,
            :context => self
          })
        end
      else
        CustomAssociation.destroy_all(:context_id => self.id, :context_type => 'Page', :field_id => field.id)
        value.to_a.each do |id|
          custom_associations << CustomAssociation.create({
            :context      => self,
            :field        => field,
            :handle       => field.handle,
            :relationship => field.relationship,
            :target_id    => id,
            :target_type  => field.target_class.to_s
          })
        end
      end
    end
  end

protected

  def method_missing_with_find_custom_associations_and_attributes(method, *args)
    # Check that we dont match any other method_missing hacks before we start query the database
    begin
      method_missing_without_find_custom_associations_and_attributes(method, *args)
    rescue NoMethodError
      if args.size == 0
        handle = method.to_s
        match  = custom_attribute_by_handle(handle) || custom_associations_by_handle(handle)
        if (match.is_a?(Array) ? match.any? : match != nil)
          unless match.is_a?(Array)
            match.value
          else
            match.first.relationship == 'one_to_one' ? match.first.target : CustomAssociationProxy.new({
              :target_class => match.first.target_type.constantize,
              :target_ids   => match.collect { |m| m.target_id }
            })
          end
        # Do we have a matching field but no records, return nil for
        # page.handle ? do stuff in the views
        elsif self.fields.count(:conditions => ['handle = ?', method.to_s]) != 0
          nil
        # no match raise method missing again
        else
          method_missing_without_find_custom_associations_and_attributes(method, *args)
        end
      else
        method_missing_without_find_custom_associations_and_attributes(method, *args)
      end
    end
  end
  alias_method_chain :method_missing, :find_custom_associations_and_attributes

private

  def custom_attribute_by_handle(handle)
    custom_attributes.detect { |cd| cd.handle == handle } || custom_attributes.find_by_handle(handle)
  end
  
  def custom_associations_by_handle(handle)
    custom_associations.find_all { |ca| ca.handle == handle } || custom_associations.find_all_by_handle(handle)
  end
    
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
