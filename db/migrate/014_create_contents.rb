class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents, :force => true do |t|
      t.integer   :page_id
      t.integer   :column_position
      t.integer   :position
      t.integer   :resource_id
      t.string    :resource_type
      t.timestamps
    end
    add_index :contents, :page_id
    add_index :contents, :resource_id
  end

  def self.down
    drop_table :contents
  end
end
