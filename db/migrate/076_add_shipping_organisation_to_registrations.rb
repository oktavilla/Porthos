class AddShippingOrganisationToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :shipping_organisation, :string
  end

  def self.down
    remove_column :registrations, :shipping_organisation
  end
end
