class RemoveAssetIncomplete < ActiveRecord::Migration
  def self.up
    remove_column :assets, :incomplete
  end

  def self.down
    add_column :assets, :incomplete, :boolean, :default => true
  end
end
