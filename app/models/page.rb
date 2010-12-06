class Page < ActiveRecord::Base

  validates_presence_of :title,
                        :field_set_id
  has_one :node,
          :as => :resource

  has_one :index_node,
          :through => :field_set,
          :source  => :node

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

  has_many :custom_association_contexts,
           :class_name => 'CustomAssociation',
           :as => :target,
           :dependent => :destroy

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
              :conditions => 'updated_at > created_at',
              :order => 'updated_at DESC'

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

  before_validation_on_create :set_inactive

  before_create :set_published_on
  before_create :set_created_by
  before_save   :set_layout_attributes,
                :generate_slug
  before_update :set_updated_by

  acts_as_list :scope => 'field_set_id'
  acts_as_taggable
  acts_as_filterable

  searchable :auto_index => false do
    integer :field_set_id
    text :title, :boost => 2.0
    text :tag_names
    time :published_on
    boolean :is_active, :using => :active?
    boolean :is_restricted, :using => :restricted?
    text :body do
       contents_as_text
    end
    text :custom_attributes_values do
      custom_attributes.map { |ca| ca.value }.join(' ')
    end
    dynamic_string :custom_attributes do
      {}.tap do |hash|
        custom_associations.each do |custom_association|
          hash[custom_association.handle.to_sym] = "#{custom_association.target_type}-#{custom_association.target_id}"
        end
        custom_attributes.all.each do |custom_attribute|
          hash[custom_attribute.handle.to_sym] = !custom_attribute.value.acts_like?(:string) ? custom_attribute.value : ActionController::Base.helpers.strip_tags(custom_attribute.value)
        end
      end
    end
  end

  after_save :commit_to_sunspot

  def contents_as_text
    contents.active.collect do |content|
      def render_content(content_resource)
        if content_resource.is_a?(ContentImage) or content_resource.is_a?(ContentVideo)
          "#{content_resource.asset.title} #{content_resource.asset.description}"
        elsif content_resource.is_a?(ContentTextfield)
          content_resource.body
        elsif content_resource.is_a?(ContentTeaser)
          "#{content_resource.title} #{content_resource.body}"
        end
      end
      if !content.restricted? && !content.module?
        if content.collection?
          content.contents.collect {|c| render_content(c)}
        else
          render_content(content.resource)
        end
      end
    end.join(' ').gsub(/<\/?[^>]*>/, "")
  end

  def to_param
    "#{id}-#{slug}"
  end

  def published?
    published_on <= Time.now
  end

  def full_slug
    @full_slug ||= node ? node.slug : (index_node ? [index_node.slug, to_param].join('/') : slug)
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
          self.custom_attributes << field.data_type.new({
            :value    => value,
            :field_id => field.id,
            :handle   => field.handle,
            :context => self
          })
        end
      else
        CustomAssociation.destroy_all(:context_id => self.id, :context_type => 'Page', :field_id => field.id)
        value.to_a.reject(&:blank?).each do |association_value|
          if association_value.is_a?(StringIO) || association_value.is_a?(Tempfile)
            uploaded_asset = Asset.from_upload(:file => association_value)
            association_value = uploaded_asset.id if uploaded_asset.save
          end
          self.custom_associations << self.custom_associations.build({
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
    fields.detect { |field| field.handle == handle }
  end

  def respond_to?(method, include_private = false)
    !new_record? ? (super(method, include_private) || field_exists?(method.to_s.gsub(/\?/, ''))) : super(method, include_private)
  end

protected

  def cache_custom_attributes
    custom_attributes.each do |custom_attribute|
      self.class.send :attr_reader, custom_attribute.handle
      instance_variable_set("@#{custom_attribute.handle}".to_sym, custom_attribute.value)
    end
  end

  def method_missing_with_find_custom_associations(method, *args)
    # Check that we dont match any other method_missing hacks before we start query the database
    begin
      method_missing_without_find_custom_associations(method, *args)
    rescue
      if args.size == 0
        handle = method.to_s.gsub(/\?/, '')
        if field = fields.detect { |field| field.handle == handle }
          match = field.target_handle.blank? ? custom_associations_by_handle(handle) : custom_association_contexts_by_handle(field.target_handle)
          if match.any?
            unless field.target_handle.present?
              match.first.relationship == 'one_to_one' ? match.first.target : CustomAssociationProxy.new({
                :target_class => match.first.target_type.constantize,
                :target_ids   => match.collect { |m| m.target_id }
              })
            else
              match.first.relationship == 'one_to_one' ? match.first.context : CustomAssociationProxy.new({
                :target_class => match.first.context_type.constantize,
                :target_ids   => match.collect { |m| m.context_id }
              })
            end
          # Do we have a matching field but no records, return nil for
          # page.handle ? do stuff in the views
          else
            nil
          end
        else
          # no match raise method missing again
          method_missing_without_find_custom_associations(method, *args)
        end
      else
        method_missing_without_find_custom_associations(method, *args)
      end
    end
  end
  alias_method_chain :method_missing, :find_custom_associations

private

  def custom_associations_by_handle(handle)
    custom_associations.find_all { |ca| ca.handle == handle }
  end

  def custom_association_contexts_by_handle(handle)
    custom_association_contexts.find_all { |ca| ca.handle == handle }
  end

  def set_inactive
    self.active = false
    true
  end

  def generate_slug
    self.slug = title.parameterize unless slug.present?
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

  def commit_to_sunspot
    Delayed::Job.enqueue SunspotIndexJob.new('Page', self.id)
  end

end
