class AddOrganizationToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :organization, :string
    add_column :orders, :contact_approval, :boolean, :default => false
  end

  def self.down
    remove_column :orders, :organization
    remove_column :orders, :contact_approval
  end
end
