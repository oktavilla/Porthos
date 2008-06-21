class AddNonGpGiverToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :non_gp_giver, :boolean, :default => false
  end

  def self.down
    remove_column :registrations, :non_gp_giver
  end
end
