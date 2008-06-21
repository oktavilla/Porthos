class AddOrderPaymentResponseMessage < ActiveRecord::Migration
  def self.up
    add_column :orders, :payment_response_message, :string
  end

  def self.down
    remove_column :orders, :payment_response_message
  end
end
