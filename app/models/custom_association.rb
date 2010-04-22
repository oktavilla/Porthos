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
end