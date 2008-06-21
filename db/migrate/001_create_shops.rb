class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops, :force => true do |t|
      t.string      :name
      t.string      :slug
      t.boolean     :show_vat,     :default => true
      t.boolean     :closed,       :default => false
      t.text        :message
      t.string      :contact_phone
      t.string      :contact_email
      t.timestamps 
    end
  end

  def self.down
    drop_table :shops
  end
end
