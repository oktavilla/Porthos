class AddGiftWrappingToCartItemsAndOrderItems < ActiveRecord::Migration
  def self.up
    add_column :cart_items, :gift_wrapping, :boolean
    add_column :order_items, :gift_wrapping, :boolean
  end

  def self.down
    remove_column :cart_items, :gift_wrapping
    remove_column :order_items, :gift_wrapping
  end
end
