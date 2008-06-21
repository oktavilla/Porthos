class AddActiveToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :active, :boolean, :default => true
    Page.update_all("active = 1")
  end
  
  def self.down
    remove_column :pages, :active
  end
end