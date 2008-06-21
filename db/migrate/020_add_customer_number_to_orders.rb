class AddCustomerNumberToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :customer_number, :string
  end

  def self.down
    remove_column :orders, :customer_number
  end
end
