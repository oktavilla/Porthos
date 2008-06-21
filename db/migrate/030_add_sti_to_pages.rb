class AddStiToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :slug, :string
    add_column :pages, :type, :string
    add_column :pages, :page_collection_id, :integer
    add_index  :pages, :page_collection_id
  end

  def self.down
    remove_column :pages, :slug
    remove_column :pages, :type
    remove_column :pages, :page_collection_id
  end
end
