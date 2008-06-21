class CreateShipments < ActiveRecord::Migration
  def self.up
    create_table :shipments, :force => true do |t|
      t.integer :order_id
      t.integer :dispatch_id
      t.string  :dispatch_status
      t.string  :package_id
      t.string  :package_type
      t.integer :price
      t.timestamps
    end
    add_index :shipments, :order_id
  end

  def self.down
    drop_table :shipments
  end
end
