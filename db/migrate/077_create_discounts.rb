class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts, :force => true do |t|
      t.integer   :shop_id
      t.string    :name
      t.string    :code
      t.boolean   :free_shipping
      t.float     :price_modification
      t.datetime  :valid_from
      t.datetime  :valid_through
      t.text      :message
      t.timestamps 
    end
    add_index :discounts, :shop_id
  end

  def self.down
    drop_table :discounts
  end
end
