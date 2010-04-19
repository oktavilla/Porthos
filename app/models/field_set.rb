class FieldSet < ActiveRecord::Base
  validates_presence_of :title
  
  has_many :fields,
           :order => 'fields.position',
           :dependent => :destroy
  has_many :page_layouts
  
end