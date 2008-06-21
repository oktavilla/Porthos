class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets, :force => true do |t|
      t.string     :type
      t.string     :title
      t.string     :file_name
      t.string     :mime_type
      t.string     :extname
      t.integer    :width
      t.integer    :height
      t.integer    :size
      t.timestamps
    end
    add_index :assets, :file_name
  end

  def self.down
    drop_table :assets
  end
end