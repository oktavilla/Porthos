class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders, :force => true do |t|
      t.integer     :shop_id
      t.integer     :user_id
      t.string      :public_id
      t.integer     :type

      t.string      :first_name
      t.string      :last_name
      t.string      :email
      t.string      :cell_phone
      t.string      :phone
      t.string      :address
      t.string      :post_code
      t.string      :locality
      t.string      :shipping_address
      t.string      :shipping_post_code
      t.string      :shipping_locality

      t.decimal     :total_sum,  :precision => 8, :scale => 2, :default => 0
      t.decimal     :total_vat,  :precision => 8, :scale => 2, :default => 0
      t.integer     :total_items

      t.string      :dispatch_id
      t.string      :dispatch_status

      t.string      :shipment_id
      t.string      :shipment_type
      t.decimal     :shipment_price, :precision => 8, :scale => 2, :default => 0

      t.string      :payment_type
      t.string      :payment_transaction_id
      t.string      :payment_status

      t.timestamps
    end
    add_index :orders, :shop_id
    add_index :orders, :user_id
    add_index :orders, :dispatch_id
    add_index :orders, :payment_transaction_id
  end

  def self.down
    drop_table :orders
  end
end
