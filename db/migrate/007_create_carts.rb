class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts, :force => true do |t|
      t.integer :shop_id
      t.timestamps
    end
    add_index :carts, :shop_id
  end

  def self.down
    drop_table :carts
  end
end
