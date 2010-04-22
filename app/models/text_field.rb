class TextField < Field
  self.data_type = TextAttribute
  validates_presence_of :allow_rich_text
end