class CreateMeasurePoints < ActiveRecord::Migration
  def self.up
    create_table :measure_points, :force => true do |t|
      t.string  :name
      t.integer :link_type
      t.integer :target
      t.integer :cost
      t.string  :public_id
      t.integer :num_clicks, :default => 0
      t.integer :campaign_id
      t.integer :conversions_count, :default => 0
      t.timestamps 
    end
  end

  def self.down
    drop_table :measure_points
  end
end
