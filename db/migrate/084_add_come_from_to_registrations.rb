class AddComeFromToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :come_from, :string
  end

  def self.down
    remove_column :registrations, :come_from
  end
end
