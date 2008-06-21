class AddAvailableInPageTypeToContentModules < ActiveRecord::Migration
  def self.up
    add_column :content_modules, :available_in_page_type, :string
  end

  def self.down
    remove_column :content_modules, :available_in_page_type
  end
end
