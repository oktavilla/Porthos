class TeasersChangeResourceToParent < ActiveRecord::Migration
  def self.up
    rename_column :teasers, :resource_type, :parent_type
    rename_column :teasers, :resource_id, :parent_id
  end

  def self.down
    rename_column :teasers, :parent_type, :resouce_type
    rename_column :teasers, :parent_id, :resurce_id
  end
end
