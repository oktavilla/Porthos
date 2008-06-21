class AddChildrenCountToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :children_count, :integer
  end

  def self.down
    remove_column :nodes, :children_count
  end
end
