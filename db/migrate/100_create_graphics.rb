class CreateGraphics < ActiveRecord::Migration
  def self.up
    create_table :graphics do |t|
      t.string :title
      t.string :file_name
      t.string :mime_type
      t.string :extname
      t.integer :width
      t.integer :height
      t.integer :size

      t.timestamps 
    end
  end

  def self.down
    drop_table :graphics
  end
end
