class CreateTagCollections < ActiveRecord::Migration
  def self.up
    create_table :tag_collections, :force => true do |t|
      t.integer     :page_collection_id
      t.string      :name
      t.text        :description
      t.timestamps
    end
    add_index :tag_collections, :page_collection_id
  end

  def self.down
    drop_table :tag_collections
  end
end
