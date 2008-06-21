class AddParentToPages < ActiveRecord::Migration
  def self.up
    add_column    :pages, :position,    :integer
    add_column    :pages, :parent_id,   :integer
    add_column    :pages, :parent_type, :string
    add_index     :pages, :parent_id

    remove_column :pages, :page_collection_id
  end

  def self.down
    remove_column :pages, :position
    remove_column :pages, :parent_id
    remove_column :pages, :parent_type

    add_column    :pages, :page_collection_id, :integer
    add_index     :pages, :page_collection_id
  end
end
