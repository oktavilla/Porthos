class AddTitleToTextfields < ActiveRecord::Migration
  def self.up
    add_column :textfields, :title, :string
  end

  def self.down
    remove_column :textfields, :title
  end
end
