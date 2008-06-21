class AddShowVatToCart < ActiveRecord::Migration
  def self.up
    add_column :carts, :show_vat, :boolean, :default => nil
  end

  def self.down
    remove_column :carts, :show_vat
  end
end
