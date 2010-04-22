class PageAssociationField < Field
  validates_presence_of :association_source_id,
                        :relationship
  self.data_type = CustomAssociation
  
  def possible_targets
    @possible_targets ||= connection.select_all("SELECT id, title FROM pages WHERE page_layout_id = #{association_source_id}")
  end

  def target_class
    self.class.target_class
  end
  
  def self.target_class
    Page
  end
  
end