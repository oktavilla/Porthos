class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations, :force => true do |t|
      t.string   :type
      t.string   :first_name
      t.string   :last_name
      t.string   :customer_number
      t.integer  :age
      t.string   :email
      t.string   :phone
      t.string   :cell_phone
      t.string   :organization
      t.string   :department
      t.string   :organization_number
      t.string   :address
      t.string   :post_code
      t.string   :locality
      t.string   :country
      t.string   :shipping_address
      t.string   :shipping_post_code
      t.string   :shipping_locality
      t.string   :shipping_country
      t.boolean  :contact_approval
      t.integer  :total_sum
      t.integer  :total_vat
      t.integer  :total_items
      t.integer  :payment_id
      t.string   :payment_type
      t.string   :payment_transaction_id
      t.string   :payment_status
      t.string   :payment_response_message
      t.string   :public_id
      t.integer  :user_id
      t.integer  :shop_id
      t.string   :dispatch_id
      t.string   :dispatch_status
      t.string   :shipment_id
      t.string   :shipment_type
      t.string   :message
      t.integer  :node_id
      t.timestamps
    end
    
    add_index :registrations, :payment_id
    add_index :registrations, :payment_transaction_id
    add_index :registrations, :public_id
    add_index :registrations, :user_id
    add_index :registrations, :dispatch_id
    add_index :registrations, :shipment_id
    add_index :registrations, :node_id
  end

  def self.down
    drop_table :registrations
  end
end
