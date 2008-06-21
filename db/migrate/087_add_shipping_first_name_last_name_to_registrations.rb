class AddShippingFirstNameLastNameToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :shipping_first_name, :string
    add_column :registrations, :shipping_last_name, :string
  end

  def self.down
    remove_column :registrations, :shipping_first_name
    remove_column :registrations, :shipping_last_name
  end
end
