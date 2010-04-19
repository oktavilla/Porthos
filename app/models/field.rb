class Field < ActiveRecord::Base
  
  validates_uniqueness_of :label,
                          :handle,
                          :scope => :field_set_id

  validates_presence_of :field_set_id,
                        :label,
                        :handle
  
  acts_as_list :scope => :field_set_id
  
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