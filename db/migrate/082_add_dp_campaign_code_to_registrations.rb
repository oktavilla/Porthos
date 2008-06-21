class AddDpCampaignCodeToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :dp_campaign_code, :string
  end

  def self.down
    remove_column :registrations, :dp_campaign_code
  end
end
