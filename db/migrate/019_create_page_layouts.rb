class CreatePageLayouts < ActiveRecord::Migration
  def self.up
    create_table :page_layouts, :force => true do |t|
      t.string  :css_id
      t.string  :name
      t.integer :columns, :default => 1
      t.timestamps 
    end
  end

  def self.down
    drop_table :page_layouts
  end
end
