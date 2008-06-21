class CreateProductImages < ActiveRecord::Migration
  def self.up
    create_table :product_images, :force => true do |t|
      t.integer     :asset_id
      t.integer     :product_id
      t.integer     :position
      t.timestamps
    end
    add_index :product_images, :asset_id
    add_index :product_images, :product_id
  end

  def self.down
    drop_table :product_images
  end
end
