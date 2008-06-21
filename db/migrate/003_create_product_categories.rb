class CreateProductCategories < ActiveRecord::Migration
  def self.up
    create_table :product_categories, :force => true do |t|
      t.string      :name
      t.string      :slug
      t.integer     :parent_id
      t.integer     :shop_id
      t.integer     :position
      t.boolean     :hidden
      t.timestamps 
    end
    add_index :product_categories, :slug
    add_index :product_categories, :parent_id
    add_index :product_categories, :shop_id
  end

  def self.down
    drop_table :product_categories
  end
end
