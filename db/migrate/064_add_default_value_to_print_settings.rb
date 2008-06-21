class AddDefaultValueToPrintSettings < ActiveRecord::Migration
  def self.up
    remove_column :print_settings, :greeting_color
    add_column    :print_settings, :greeting_color, :string, :default => 'Svart'
    remove_column :print_settings, :logo_color
    add_column    :print_settings, :logo_color, :string, :default => 'Svart'
  end

  def self.down
    
  end
end