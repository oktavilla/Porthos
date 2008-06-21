class AddMinQuantityToProductCategorization < ActiveRecord::Migration
  def self.up
    add_column :product_categorizations, :min_quantity, :integer, :default => 1
    add_column :cart_items, :min_quantity, :integer, :default => 1
  end

  def self.down
    remove_column :product_categorizations, :min_quantity
    remove_column :cart_items, :min_quantity
  end
end
