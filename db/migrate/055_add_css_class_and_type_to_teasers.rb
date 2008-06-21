class AddCssClassAndTypeToTeasers < ActiveRecord::Migration
  def self.up
    add_column :teasers, :css_class, :string
    add_column :teasers, :display_type, :string
  end

  def self.down
    remove_column :teasers, :css_class
    remove_column :teasers, :display_type
  end
end
