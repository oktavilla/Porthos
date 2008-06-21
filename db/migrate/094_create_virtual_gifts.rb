class CreateVirtualGifts < ActiveRecord::Migration
  def self.up
    create_table :virtual_gifts, :force => true do |t|
      t.string     :name
      t.text       :description
      t.integer    :price, :default => 0
      t.boolean    :active
      t.timestamps 
    end
  end

  def self.down
    drop_table :virtual_gifts
  end
end
