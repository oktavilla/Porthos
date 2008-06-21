class AddProductCategoryToRegistrationForm < ActiveRecord::Migration
  def self.up
    add_column :registration_forms, :product_category_id, :integer
    create_table :sample_product_order_items, :force => true do |t|
      t.integer :sample_product_order_id
      t.string  :article_number
      t.timestamps
    end
    add_index :sample_product_order_items, :sample_product_order_id
  end

  def self.down
    remove_column :registration_forms, :product_category_id
    drop_table :sample_product_order_items
  end
end
