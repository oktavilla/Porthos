class CreateContentImages < ActiveRecord::Migration
  def self.up
    create_table :content_images, :force => true do |t|
      t.integer :image_asset_id
      t.string  :title
      t.text    :caption
      t.string  :copyright
      t.string  :style
      t.timestamps 
    end
    add_index :content_images, :image_asset_id
  end

  def self.down
    drop_table :content_images
  end
end
