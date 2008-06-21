class CreateVgCartItems < ActiveRecord::Migration
  def self.up
    create_table :vg_cart_items, :force => true do |t|
      t.integer :vg_cart_id
      t.string  :name
      t.integer :price
      t.integer :quantity
      t.integer :virtual_gift_id
      t.timestamps 
    end
    add_index :vg_cart_items, :vg_cart_id
    add_index :vg_cart_items, :virtual_gift_id
  end

  def self.down
    drop_table :vg_cart_items
  end
end
