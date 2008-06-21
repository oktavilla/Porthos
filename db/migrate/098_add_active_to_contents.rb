class AddActiveToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :active, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :contents, :active
  end
end
