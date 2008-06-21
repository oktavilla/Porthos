class ConvertBigDecimalFieldsToPennyIntegers < ActiveRecord::Migration
  def self.up
    remove_column :products,    :price
    remove_column :order_items, :price
    remove_column :orders,      :total_sum
    remove_column :orders,      :total_vat
    remove_column :orders,      :shipment_price

    add_column :products,       :price,            :integer, :default => 0
    add_column :order_items,    :price,            :integer, :default => 0
    add_column :orders,         :total_sum,        :integer, :default => 0
    add_column :orders,         :total_vat,        :integer, :default => 0
    add_column :orders,         :shipment_price,   :integer, :default => 0
  end

  def self.down
    remove_column :products,    :price
    remove_column :order_items, :price
    remove_column :orders,      :total_sum
    remove_column :orders,      :total_vat
    remove_column :orders,      :shipment_price
    
    add_column :products,       :price,            :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :order_items,    :price,            :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :orders,         :total_sum,        :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :orders,         :total_vat,        :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :orders,         :shipment_price,   :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
