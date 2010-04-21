class AssociationField < Field
  validates_presence_of :association_source_id
  self.data_type = CustomAssociation
end