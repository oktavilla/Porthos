class AddCreatedByToPages < ActiveRecord::Migration

  def self.up
    add_column :pages, :created_by_id, :integer
    add_column :pages, :updated_by_id, :integer
  end
  
  def self.down
    remove_column :pages, :created_by_id
    remove_column :pages, :updated_by_id
  end
  
end