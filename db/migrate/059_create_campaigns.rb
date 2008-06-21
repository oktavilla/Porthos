class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns, :force => true do |t|
      t.string  :name
      t.string  :dp_global_parent_code
      t.string  :dp_buyer_code
      t.string  :dp_donor_code
      t.boolean :active, :default => true
      t.timestamps 
    end
  end

  def self.down
    drop_table :campaigns
  end
end
