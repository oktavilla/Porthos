class AddCoAddressToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :co_address, :string
    add_column :registrations, :shipping_co_address, :string
  end

  def self.down
    remove_column :registrations, :co_address
    remove_column :registrations, :shipping_co_address
  end
end