class AddAuthorAndDescriptionToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :author, :text, :null => :yes
    add_column :assets, :description, :text, :null => :yes
    add_column :assets, :created_by, :integer, :null => :yes
    add_column :assets, :incomplete, :integer, :size => 1, :default => 0
  end

  def self.down
    remove_column :assets, :author
    remove_column :assets, :description
    remove_column :assets, :created_by
    remove_column :assets, :incomplete
  end
end
