class AddCalendarOption < ActiveRecord::Migration
  def self.up
    add_column :pages, :calendar, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :calendar
  end
end
