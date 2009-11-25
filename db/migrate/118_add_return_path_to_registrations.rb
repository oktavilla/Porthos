class AddReturnPathToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :return_path, :string
  end

  def self.down
    remove_column :registrations, :return_path
  end
end