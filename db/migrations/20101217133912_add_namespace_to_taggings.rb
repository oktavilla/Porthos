class AddNamespaceToTaggings < ActiveRecord::Migration
  def self.up
    add_column :taggings, :namespace, :string
    add_column :field_sets, :allow_categories, :boolean, :default => false
  end

  def self.down
    remove_column, :taggings, :namespace
    remove_column, :field_sets, :allow_categories
  end
end
