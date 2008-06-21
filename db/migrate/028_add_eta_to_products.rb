class AddEtaToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :eta, :string
  end

  def self.down
    remove_column :products, :eta
  end
end
