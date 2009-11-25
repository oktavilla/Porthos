class RemoveAvailableInPageTypesFromContentModules < ActiveRecord::Migration
  def self.up
    remove_column :content_modules, :available_in_page_type
  end

  def self.down
    add_column :content_modules, :available_in_page_type, :string
  end
end
