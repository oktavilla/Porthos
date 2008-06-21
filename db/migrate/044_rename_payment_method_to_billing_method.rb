class RenamePaymentMethodToBillingMethod < ActiveRecord::Migration
  def self.up
    rename_column :payments, :method, :billing_method
  end

  def self.down
    rename_column :payments, :billing_method, :method
  end
end
