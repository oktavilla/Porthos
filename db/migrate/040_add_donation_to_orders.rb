class AddDonationToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :donation, :integer, :default => 0
    add_column :carts, :donation, :integer, :default => 0
  end

  def self.down
    remove_column :orders, :donation
    remove_column :carts, :donation
  end
end
