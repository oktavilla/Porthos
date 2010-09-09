class CreateFieldSets < ActiveRecord::Migration
  def self.up
    create_table :field_sets do |t|
      t.string :title
      t.text   :description
      t.timestamps
    end
    
    add_column :page_layouts, :field_set_id, :integer
    add_index  :page_layouts, :field_set_id
  end
  
  def self.down
    drop_table :field_sets
    remove_column :page_layouts, :field_set_id
  end
end