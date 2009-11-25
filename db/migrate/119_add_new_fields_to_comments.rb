class AddNewFieldsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :ip_address, :string
    add_column :comments, :url, :string
  end

  def self.down
    remove_column :comments, :ip_address
    remove_column :comments, :url
  end
end