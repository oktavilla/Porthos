class AddMissingOrderColumnsToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :donation,       :integer
    add_column :registrations, :shipment_price, :integer
  end

  def self.down
    remove_column :registrations, :donation
    remove_column :registrations, :shipment_price
  end
end
