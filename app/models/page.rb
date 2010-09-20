class Page < ActiveRecord::Base
  
  validates_presence_of :title,
                        :field_set_id
  has_one :node,
          :as => :resource
  accepts_nested_attributes_for :node
  
  has_many :contents,
           :as    => :context,
           :order => :position,
           :conditions => ["contents.parent_id IS NULL"],
           :dependent  => :destroy

  belongs_to :field_set
  has_many :fields,
           :through => :field_set
  
  delegate :template,
           :to => :field_set
  
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

  has_many :comments,
           :as => :commentable,
           :order => 'comments.created_at'
  
  named_scope :published, lambda {{
    :conditions => ["published_on <= ?", Time.now]
  }}
              
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
    :conditions => ['restricted = ? or restricted = ?', restricted, false]
  }}

  named_scope :created_latest, 
              :order => 'created_at DESC'
              
  named_scope :updated_latest, 
              :conditions => 'changed_at > created_at', 
              :order => 'changed_at DESC'

  named_scope :filter_with_field_set, lambda { |field_set_id| {
    :conditions => ["field_set_id = ?", field_set_id]
  }}

  named_scope :filter_created_by, lambda { |user_id| {
    :conditions => ["created_by_id = ?", user_id]
  }}

  named_scope :filter_updated_by, lambda { |user_id| {
    :conditions => ["updated_by_id = ?", user_id]
  }}

  named_scope :filter_order_by, lambda { |order| {
    :order => order
  }}
  
  named_scope :filter_active, lambda { |active| {
    :conditions => ["active = ?", active]
  }}
  
  named_scope :filter_with_unpublished_changes,
              :conditions => ["changed_at > changes_published_at AND rendered_body IS NOT NULL"]
  
  before_validation_on_create :set_inactive

  before_create :set_published_on
  before_create :set_created_by
  before_save   :set_layout_attributes,
                :generate_slug
  before_update :set_updated_by

  acts_as_list :scope => 'field_set_id'
  acts_as_taggable
  acts_as_filterable  
  
  searchable do
    integer :field_set_id
    text :title, :boost => 2.0
    text :description ,:rendered_body, :tag_names
    time :published_on
    boolean :is_active, :using => :active?
    text :custom_attributes_values do
      custom_attributes.map { |ca| 
        "#{ca.string_value||ca.text_value||ca.date_time_value.to_s(:db)}" 
      }
    end
    dynamic_string :custom_attributes do
      returning Hash.new do |attributes|
        custom_attributes.each do |ca|
          attributes[ca.handle.to_sym] = (ca.string_value||ca.text_value||ca.date_time_value.to_s(:db))
        end
        custom_associations.each do |ca|
          attributes[ca.handle.to_sym] = "#{ca.target_type}-#{ca.target_id}"
        end
      end
    end
  end
    
  def published?
    published_on <= Time.now
  end

  def unpublished_changes?
    if !changes_published_at.nil? && !changed_at.nil?
      changed_at > changes_published_at
    else
      !changed_at.nil?
    end
  end

  def full_slug
    node ? node.slug : slug
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
            :value    => value,
            :field_id => field.id,
            :handle   => field.handle,
            :context  => self
          })
        end
      else
        CustomAssociation.destroy_all(:context_id => self.id, :context_type => 'Page', :field_id => field.id)
        value.to_a.reject(&:blank?).each do |association_value|
          if association_value.is_a?(StringIO) || association_value.is_a?(Tempfile)
            uploaded_asset = Asset.from_upload(:file => association_value)
            association_value = uploaded_asset.id if uploaded_asset.save
          end
          custom_associations << CustomAssociation.create({
            :context      => self,
            :field        => field,
            :handle       => field.handle,
            :relationship => field.relationship,
            :target_id    => association_value,
            :target_type  => field.target_class.to_s
          })
        end
      end
    end
  end

  def field_exists?(handle)
    self.fields.count(:conditions => ['fields.handle = ?', handle]) != 0
  end

protected

  def method_missing_with_find_custom_associations_and_attributes(method, *args)
    # Check that we dont match any other method_missing hacks before we start query the database
    begin
      method_missing_without_find_custom_associations_and_attributes(method, *args)
    rescue NoMethodError
      if args.size == 0
        handle = method.to_s
        if field_exists?(handle)
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
          else
            nil
          end
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
    self.active = false
    true
  end

  def generate_slug
    self.slug = title.parameterize
  end

  def set_published_on
    self.published_on = Time.now if published_on.blank?
  end

  def set_layout_attributes
    contents.update_all("column_position = #{template.columns}", "column_position > #{template.columns}") unless column_count == template.columns or column_count.blank?
    self.layout_class = template.handle
    self.column_count = template.columns
  end

  def set_created_by
    self.created_by = User.current
  end

  def set_updated_by
    self.updated_by = User.current
  end

end
