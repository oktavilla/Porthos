class CreateFields < ActiveRecord::Migration
  def self.up
    create_table :fields do |t|
      t.string  :type
      t.integer :field_set_id
      t.string  :label
      t.string  :handle
      t.integer :position
      t.boolean :required, :default => false
      t.text    :instructions
      t.boolean :allow_rich_text, :default => false
      t.integer :association_source_id
      t.timestamps
    end
    
    add_index  :fields, :field_set_id
  end
  
  def self.down
    drop_table :fields
  end
end