class AddMissingDbIndexes < ActiveRecord::Migration
  def self.up
    add_index :pages,    :slug
    add_index :nodes,    :slug
    add_index :orders,   :public_id
    add_index :taggings, :tag_id
    add_index :taggings, :taggable_id
    add_index :tags,     :name
  end

  def self.down
    remove_index :pages,    :slug
    remove_index :nodes,    :slug
    remove_index :orders,   :public_id
    remove_index :taggings, :tag_id
    remove_index :taggings, :taggable_id
    remove_index :tags,     :name
  end
end
