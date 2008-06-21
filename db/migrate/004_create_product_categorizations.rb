class CreateProductCategorizations < ActiveRecord::Migration
  def self.up
    create_table :product_categorizations, :force => true do |t|
      t.integer :product_category_id
      t.integer :product_id
      t.integer :position
      t.timestamps 
    end
    add_index :product_categorizations, :product_category_id
    add_index :product_categorizations, :product_id
  end

  def self.down
    drop_table :product_categorizations
  end
end
