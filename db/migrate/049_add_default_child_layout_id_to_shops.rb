class AddDefaultChildLayoutIdToShops < ActiveRecord::Migration
  def self.up
    add_column :shops, :default_child_layout_id, :integer, :default => nil
    add_index :shops, :default_child_layout_id
  end

  def self.down
    remove_column :shops, :default_child_layout_id
  end
end
