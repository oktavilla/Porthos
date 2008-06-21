class CreateVgCategories < ActiveRecord::Migration
  def self.up
    create_table :vg_categories, :force => true do |t|
      t.string    :name
      t.text      :description
      t.integer   :position
      t.boolean   :active
      t.timestamps 
    end
  end

  def self.down
    drop_table :vf_categories
  end
end
