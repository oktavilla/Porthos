class CreatePagePresets < ActiveRecord::Migration
  def self.up
    create_table :page_presets do |t|
      t.integer :graphic_id
      t.string :name
      t.string :description
      t.integer :page_collection_id
      t.integer :page_layout_id

      t.timestamps 
    end
  end

  def self.down
    drop_table :page_presets
  end
end
