class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes, :force => true do |t|
      t.integer :parent_id
      t.string  :name
      t.string  :slug
      t.integer :status, :size => 1, :default => 0
      t.integer :position
      t.string  :controller
      t.string  :action
      t.string  :resource_type
      t.integer :resource_id
      t.timestamps 
    end
    add_index :nodes, :parent_id
    add_index :nodes, :resource_id
  end

  def self.down
    drop_table :nodes
  end
end
