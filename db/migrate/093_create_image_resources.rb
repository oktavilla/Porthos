class CreateImageResources < ActiveRecord::Migration
  def self.up
    create_table :image_resources, :force => true do |t|
      t.integer   :image_asset_id
      t.integer   :parent_id
      t.string    :parent_type
      t.integer   :position
      t.timestamps 
    end
    add_index :image_resources, :image_asset_id
    add_index :image_resources, :parent_id
  end

  def self.down
    drop_table :virtual_gift_images
  end
end
