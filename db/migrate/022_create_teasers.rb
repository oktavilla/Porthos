class CreateTeasers < ActiveRecord::Migration
  def self.up
    create_table :teasers do |t|
      t.string  :title
      t.string  :body
      t.string  :link
      t.string  :resource_type
      t.integer :resource_id
      t.integer :image_asset_id
      t.timestamps
    end
    add_index :teasers, :resource_id
    add_index :teasers, :image_asset_id
  end

  def self.down
    drop_table :teasers
  end
end
