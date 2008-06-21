class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages, :force => true do |t|
      t.string   :title
      t.text     :description
      t.integer  :page_layout_id
      t.string   :layout_class
      t.integer  :column_count
      t.datetime :published_on
      t.timestamps
    end
    add_index :pages, :page_layout_id
  end

  def self.down
    drop_table :pages
  end
end
