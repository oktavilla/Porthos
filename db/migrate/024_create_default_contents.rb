class CreateDefaultContents < ActiveRecord::Migration
  def self.up
    create_table :default_contents, :force => true do |t|
      t.integer :position
      t.integer :column_position
      t.integer :page_layout_id
      t.string  :resource_type
      t.integer :resource_id
      t.timestamps
    end
    add_index :default_contents, :page_layout_id
    add_index :default_contents, :resource_id
  end

  def self.down
    drop_table :default_contents
  end
end
