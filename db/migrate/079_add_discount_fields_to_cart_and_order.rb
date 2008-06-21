class AddDiscountFieldsToCartAndOrder < ActiveRecord::Migration
  def self.up
    add_column :carts, :discount_id, :integer
    add_index  :carts, :discount_id

    add_column :registrations, :discount_id, :integer
    add_index  :registrations, :discount_id
  end

  def self.down
    remove_column :carts, :discount_id
    remove_column :registrations, :discount_id
  end
end
