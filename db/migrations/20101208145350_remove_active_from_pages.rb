class RemoveActiveFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :active
  end

  def self.down
    add_column :pages, :active, :boolean, :default => false
  end
end
