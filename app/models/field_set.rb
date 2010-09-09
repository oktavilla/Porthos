class FieldSet < ActiveRecord::Base
  validates_presence_of :title,
                        :handle
  validates_uniqueness_of :title,
                          :handle
  
  has_many :fields,
           :order => 'fields.position',
           :dependent => :destroy
           
  has_many :pages

  before_validation :parameterize_handle
  
protected

  def parameterize_handle
    self.handle = handle.parameterize
  end

end