class UpdateStatusForProductCategories < ActiveRecord::Migration
  def self.up
    remove_column :product_categories, :hidden
    add_column    :product_categories, :status, :integer, :default => 0
  end

  def self.down
    remove_column :product_categories, :status
    add_column    :product_categories, :hidden, :boolean
  end
end
