class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings, :force => true do |t|
      t.string      :settingable_type
      t.string      :settingable_id
      t.string      :name
      t.text        :value
      t.timestamps
    end
    add_index :settings, :name
  end

  def self.down
    drop_table :settings
  end
end
