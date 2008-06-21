class AddParentToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :parent_id, :integer
  end
  
  def self.down
    remove_column :assets, :parent_id
  end
end