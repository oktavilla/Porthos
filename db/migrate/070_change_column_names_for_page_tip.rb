class ChangeColumnNamesForPageTip < ActiveRecord::Migration
  def self.up
    rename_column :registrations, :reciver_name, :uri
    rename_column :registrations, :reciver_email, :recipients
  end

  def self.down
    rename_column :registrations, :uri, :reciver_name
    rename_column :registrations, :recipients, :reciver_email
  end
end
