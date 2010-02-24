class Textfield < ActiveRecord::Base
  include Porthos::ContentResource
  
  has_many :contents, :as => :resource
  has_many :default_contents, :as => :resource
  validates_presence_of :body, :on => :update
  validates_presence_of :title, :on => :update, :if => Proc.new { |textfield| textfield.shared? }  
  before_destroy do |textfield|
    if textfield.shared? and textfield.contents.any?
      textfield.contents.destroy_all
    end
  end
  
  # FIXME: We need to check if we no longer is a shared content and if not create a new instance and save that instead
  # before_update do |textfield|
  # end
  
  named_scope :shared, :conditions => ["shared = ?", 1]
  
  @@filters = %w(wymeditor html textile none)
  @@default_filter = 'wymeditor'
  cattr_accessor :filters
  cattr_accessor :default_filter
  
  def filter
    @filter ||= read_attribute(:filter) || default_filter
  end
  
end
