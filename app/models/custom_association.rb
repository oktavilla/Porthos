class CustomAssociation < ActiveRecord::Base
  belongs_to :context,
             :polymorphic => true
  belongs_to :target,
             :polymorphic => true
  belongs_to :field
  validates_presence_of :context_id,
                        :target_id,
                        :field_id,
                        :handle,
                        :relationship

  named_scope :with_field, lambda { |field_id| {
    :conditions => ['field_id = ?', field_id]
  }}

  before_validation :parameterize_handle

protected

  def parameterize_handle
    self.handle = handle.parameterize
  end
  
end