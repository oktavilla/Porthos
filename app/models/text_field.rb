class TextField < Field

  validates_presence_of :allow_rich_text

  self.data_type = TextAttribute
  cattr_accessor :data_type

end