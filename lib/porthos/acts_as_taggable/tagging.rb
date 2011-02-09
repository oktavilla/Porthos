class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true, :touch => true

  named_scope :with_taggable_type, lambda { |type| {
   :conditions => ["taggings.taggable_type = ? ", type]
  }}

  named_scope :with_namespace, lambda { |namespace| {
    :conditions => ["taggings.namespace = ?", namespace]
  }}

  named_scope :without_namespace, {
    :conditions => ["taggings.namespace IS NULL"]
  }

end
