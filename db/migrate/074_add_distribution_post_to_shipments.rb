class AddDistributionPostToShipments < ActiveRecord::Migration
  def self.up
    add_column :shipments, :distribution_post_vars, :text
  end

  def self.down
    remove_column :shipments, :distribution_post_vars
  end
end
