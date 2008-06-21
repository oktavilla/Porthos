class CreateVgCarts < ActiveRecord::Migration
  def self.up
    create_table :vg_carts, :force => true do |t|
      t.timestamps 
    end
    add_column :registrations, :cart_id, :integer
    add_index  :registrations, :cart_id
  end

  def self.down
    drop_table :vg_carts
    remove_column :registrations, :cart_id
  end
end
