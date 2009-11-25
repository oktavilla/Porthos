class AddMainContentColumnToLayouts < ActiveRecord::Migration
  def self.up
    add_column :page_layouts, :main_content_column, :integer
    add_column :pages, :main_content_column, :integer
  end

  def self.down
    remove_column :page_layouts, :main_content_column
    remove_column :pages, :main_content_column
  end
end
