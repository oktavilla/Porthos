class ChristmasCompanyDonation < ActiveRecord::Migration
  def self.up
    add_column :registrations, :ecard_image_id, :integer
    add_column :registrations, :company_logo_id, :integer
  end

  def self.down
    remove_column :registrations, :ecard_image_id
    remove_column :registrations, :company_logo_id
  end
end
