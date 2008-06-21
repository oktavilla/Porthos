class AddActivityGroupIdToRegistrations < ActiveRecord::Migration
  def self.up
    add_index :registrations, :activity_group_id
  end

  def self.down
    remove_index :registrations, :activity_group_id
  end
end
