class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments, :force => true do |t|
      t.string  :payable_type
      t.integer :payable_id
      t.boolean :recurring
      t.string  :method
      t.string  :transaction_id
      t.string  :status
      t.string  :response_message
      t.integer :amount
      t.timestamps 
    end
  end

  def self.down
    drop_table :payments
  end
end
