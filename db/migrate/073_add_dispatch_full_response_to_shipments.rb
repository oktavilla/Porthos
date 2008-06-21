class AddDispatchFullResponseToShipments < ActiveRecord::Migration
  def self.up
    add_column :shipments, :dispatch_full_response, :text
  end

  def self.down
    remove_column :shipments, :dispatch_full_response
  end
end
