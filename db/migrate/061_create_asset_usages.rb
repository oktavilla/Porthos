class CreateAssetUsages < ActiveRecord::Migration
  def self.up
    create_table :asset_usages, :force => true do |t|
      t.integer :asset_id
      t.integer :resource_id
      t.string  :resource_type
      t.integer :position
      t.timestamps 
    end
  end

  def self.down
    drop_table :asset_usages
  end
end
