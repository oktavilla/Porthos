class RemoveUnicefTables < ActiveRecord::Migration
  def self.up
    raise "This migration will remove UNICEF specfic tables" if RAILS_ROOT.include?('unicef')
    [ :activity_groups, :carts, :credit_check_responses, :discounteds,
      :discounts,:global_parent_give_away_recipients, :order_items, :orders, 
      :print_settings, :product_categories, :product_categorizations, :product_images, 
      :products, :sample_product_order_items, :shipments, :shops, :vg_cart_items, :vg_carts, 
      :vg_categories, :vg_categorizations, :virtual_gifts
    ].each { |table| drop_table table if ActiveRecord::Base.connection.tables.include?(table.to_s) }
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end