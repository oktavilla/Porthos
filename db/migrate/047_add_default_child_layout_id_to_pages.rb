class AddDefaultChildLayoutIdToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :default_child_layout_id, :integer, :default => nil
    add_index :pages, :default_child_layout_id
  end

  def self.down
    remove_column :pages, :default_child_layout_id
  end
end
