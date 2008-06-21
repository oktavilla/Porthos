class AddProductAndProductCategoryToTeasers < ActiveRecord::Migration
  def self.up
    add_column :teasers, :product_category_id, :integer
    add_column :teasers, :product_id, :integer
    add_column :teasers, :position, :integer

    add_index :teasers, :product_category_id
    add_index :teasers, :product_id

  end

  def self.down
    remove_column :teasers, :product_category_id
    remove_column :teasers, :product_id
    remove_column :teasers, :position
  end
end
