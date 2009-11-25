class Tag < ActiveRecord::Base
  has_many :taggings
  named_scope :popular, :select => "tags.*, COUNT(taggings.tag_id) as num_taggings", :joins => "LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id", :order => "num_taggings DESC", :group => "tags.id"
  named_scope :on, lambda { |taggable_type| { :conditions => ["taggings.taggable_type = ?", taggable_type.to_s.classify], :joins => "LEFT OUTER JOIN taggings ON taggings.tag_id = tags.id" } }

  def self.delimiter
    ' '
  end

end
