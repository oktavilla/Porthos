class CreateVgCategorizations < ActiveRecord::Migration
  def self.up
    create_table :vg_categorizations, :force => true do |t|
      t.integer   :vg_category_id
      t.integer   :virtual_gift_id
      t.integer   :position
      t.timestamps 
    end
    add_index :vg_categorizations, :vg_category_id
    add_index :vg_categorizations, :virtual_gift_id
  end

  def self.down
    drop_table :vf_categorizations
  end
end
