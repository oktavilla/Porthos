class CreateTextfields < ActiveRecord::Migration
  def self.up
    create_table :textfields, :force => true do |t|
      t.boolean :shared,    :default => false
      t.string  :filter
      t.string  :class_name
      t.text    :body
      t.timestamps
    end
  end

  def self.down
    drop_table :textfields
  end
end
