class CreateCreditCheckResponses < ActiveRecord::Migration
  def self.up
    create_table :credit_check_responses, :force => true do |t|
      t.boolean :approved
      t.string  :message
      t.text    :serialized_products
      t.string  :hash
      t.timestamps
    end
  end

  def self.down
    drop_table :credit_check_responses
  end
end
