class TagCollection < ActiveRecord::Base
  belongs_to :page_collection
  acts_as_taggable
  validates_presence_of :name, :page_collection_id
  
  def querystring
    @querystring ||= tags.collect { |tag| "tags[]=#{tag.name}" }.join('&') + "&tag_collection_id=#{id}"
  end
  
end