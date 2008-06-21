class AddResultCodeToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :result_code, :string
  end

  def self.down
    remove_column :payments, :result_code
  end
end
