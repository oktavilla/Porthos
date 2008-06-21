class CreateDiscounteds < ActiveRecord::Migration
  def self.up
    create_table :discounteds do |t|
      t.integer :discount_id
      t.integer :discountable_id
      t.string  :discountable_type
      t.timestamps 
    end
    add_index :discounteds, :discount_id
    add_index :discounteds, :discountable_id
  end

  def self.down
    drop_table :discounteds
  end
end
