class CreateConversions < ActiveRecord::Migration
  def self.up
    create_table :conversions, :force => true do |t|
      t.integer :measure_point_id
      t.integer :registration_id
      t.string  :registration_type
      t.integer :amount
      t.timestamps 
    end
  end

  def self.down
    drop_table :conversions
  end
end
