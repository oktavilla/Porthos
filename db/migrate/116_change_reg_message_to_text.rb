class ChangeRegMessageToText < ActiveRecord::Migration
  def self.up
    change_column :registrations, :message, :text
  end

  def self.down
    change_column :registrations, :message, :string
  end
end