class AddTargetToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :target_code, :string
  end

  def self.down
    remove_column :registrations, :target_code
  end
end
