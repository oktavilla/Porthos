class CreateRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects, :force => true do |t|
      t.string      :path
      t.string      :target
      t.timestamps
    end
  end

  def self.down
    drop_table :redirects
  end
end
