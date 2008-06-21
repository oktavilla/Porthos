class AddDisplayTypeToTeasers < ActiveRecord::Migration
  def self.up
    add_column :teasers, :images_display_type, :integer, :default => 0
  end

  def self.down
    remove_column :teasers, :images_display_type
  end
end
