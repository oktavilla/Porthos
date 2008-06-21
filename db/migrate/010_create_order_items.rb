class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items, :force => true do |t|
      t.integer     :order_id
      t.integer     :product_id
      t.string      :name
      t.string      :article_number
      t.decimal     :price,           :precision => 8, :scale => 2, :default => 0
      t.float       :vat,             :precision => 2
      t.integer     :quantity
    end
    add_index :order_items, :order_id
    add_index :order_items, :product_id
  end

  def self.down
    drop_table :order_items
  end
end
