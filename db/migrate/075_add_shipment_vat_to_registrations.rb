class AddShipmentVatToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :shipment_vat, :integer, :default => 0
    add_column :shipments, :vat, :integer, :default => 0
  end

  def self.down
    remove_column :registrations, :shipment_vat
    remove_column :shipments, :vat
  end
end
