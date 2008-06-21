class AddRestrictedToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :restricted, :boolean, :default => false
  end

  def self.down
    remove_column :nodes, :restricted
  end
end
