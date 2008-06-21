class CreateTrackingPoints < ActiveRecord::Migration
  def self.up
    create_table :tracking_points do |t|
      t.string :name
      t.string :template
      t.string :parent_type
      t.string :parent_id
      t.string :event
      t.string :checksum
      t.timestamps 
    end
  end

  def self.down
    drop_table :tracking_points
  end
end
