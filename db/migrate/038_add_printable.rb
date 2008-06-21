class AddPrintable < ActiveRecord::Migration
  def self.up
    add_column :products,    :printable, :boolean, :default => false
    add_column :shops,       :allow_printable, :boolean, :default => false
    add_column :cart_items,  :print_setting_id, :integer
    add_column :order_items, :print_setting_id, :integer 
  end

  def self.down
    remove_column :products,    :printable
    remove_column :shops,       :allow_printable
    remove_column :cart_items,  :print_setting_id
    remove_column :order_items, :print_setting_id
  end
end
