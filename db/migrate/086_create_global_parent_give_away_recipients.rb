class CreateGlobalParentGiveAwayRecipients < ActiveRecord::Migration
  def self.up
    create_table :global_parent_give_away_recipients do |t|
      t.integer :global_parent_give_away_id
      
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :post_code
      t.string :locality
      t.string :period

      t.timestamps 
    end
  end

  def self.down
    drop_table :global_parent_give_away_recipients
  end
end
