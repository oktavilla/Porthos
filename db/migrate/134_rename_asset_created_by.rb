class RenameAssetCreatedBy < ActiveRecord::Migration
  def self.up
    rename_column :assets, :created_by, :created_by_id
  end

  def self.down
    rename_column :assets, :created_by_id, :created_by
  end
end