class CreateContentModules < ActiveRecord::Migration
  def self.up
    create_table :content_modules, :force => true do |t|
      t.string :name
      t.string :template
      t.timestamps 
    end
  end

  def self.down
    drop_table :content_modules
  end
end
