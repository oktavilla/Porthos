class AddOrganisationTypeToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :organization_type, :string
  end

  def self.down
    remove_column :registrations, :organization_type
  end
end
