class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products, :force => true do |t|
      t.string      :name
      t.text        :short_description
      t.text        :long_description
      t.string      :article_number
      t.decimal     :price,             :precision => 8, :scale => 2, :default => 0
      t.float       :vat,               :precision => 2
      t.integer     :quantity
      t.boolean     :hidden,            :default => false
      t.timestamps 
    end
    add_index :products, :article_number
  end

  def self.down
    drop_table :products
  end
end
