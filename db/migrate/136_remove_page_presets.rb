class RemovePagePresets < ActiveRecord::Migration

  def self.up
    drop_table :page_restrictions
  end
  
  def self.down
    create_table :page_presets do |t|
      t.integer   :graphic_id
      t.string    :name
      t.string    :description
      t.integer   :page_collection_id
      t.integer   :page_layout_id
      t.timestamps 
    end
  end
  
end