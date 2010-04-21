class CustomAssociation < ActiveRecord::Base
  belongs_to :context,
             :polymorphic => true
  belongs_to :target,
             :polymorphic => true  
end