class AssetAssociationField < Field
  validates_presence_of :relationship
  self.data_type = CustomAssociation
  
  def possible_targets
    @possible_targets ||= connection.select_all("SELECT id, title FROM assets")
  end
  
  def target_class
    self.class.target_class
  end
  
  def self.target_class
    Asset
  end
  
end