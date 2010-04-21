class Field < ActiveRecord::Base

  has_many :custom_attributes,
           :dependent => :destroy
           
  has_many :custom_associations,
           :dependent => :destroy
  
  validates_uniqueness_of :label,
                          :handle,
                          :scope => :field_set_id

  validates_presence_of :field_set_id,
                        :label,
                        :handle
  
  acts_as_list :scope => :field_set_id

  class_inheritable_accessor :data_type
  
  class << self
  
    def types
      [
        StringField,
        DateTimeField,
        AssociationField
      ]
    end
    
  end
  
end