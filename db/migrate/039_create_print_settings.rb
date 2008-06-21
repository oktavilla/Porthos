class CreatePrintSettings < ActiveRecord::Migration
  def self.up
    create_table :print_settings do |t|
      t.string :predef_greeting
      t.string :greeting_text
      t.string :greeting_color
      t.string :greeting_font
      t.string :logo_file_name
      t.string :logo_color
      t.string :signature_file_name
      t.string :delivery_date
      t.string :comments

      t.timestamps 
    end
  end

  def self.down
    drop_table :print_settings
  end
end
