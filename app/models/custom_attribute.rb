class CustomAttribute < ActiveRecord::Base
  class_inheritable_accessor :value_attribute

  belongs_to :context,
             :polymorphic => true

  belongs_to :field
  
  def value=(value)
    write_attribute(self.value_attribute, value)
  end
  
  def value
    read_attribute(self.value_attribute)
  end
  
end