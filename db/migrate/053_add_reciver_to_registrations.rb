class AddReciverToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :reciver_name, :string
    add_column :registrations, :reciver_email, :string
  end

  def self.down
    remove_column :registrations, :reciver_name
    remove_column :registrations, :reciver_email
  end
end
