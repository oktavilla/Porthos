class CreateContentLists < ActiveRecord::Migration
  def self.up
    create_table :content_lists do |t|
      t.string :name
      t.string :handle
      t.timestamps
    end
    
    add_index :content_lists, :handle
  end

  def self.down
    drop_table :content_lists
  end
end
