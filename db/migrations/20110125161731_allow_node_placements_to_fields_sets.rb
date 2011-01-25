class AllowNodePlacementsToFieldsSets < ActiveRecord::Migration
  def self.up
    add_column :field_sets, :allow_node_placements, :boolean, :default => false
  end

  def self.down
    remove_column :field_sets, :allow_node_placements
  end
end
