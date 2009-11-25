class AddGravityToAssetUsages < ActiveRecord::Migration
  def self.up
    add_column :asset_usages, :gravity, :string
  end

  def self.down
    remove_column :asset_usages, :gravity
  end
end
