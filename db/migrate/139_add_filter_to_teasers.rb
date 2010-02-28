class AddFilterToTeasers < ActiveRecord::Migration
  def self.up
    add_column :teasers, :filter, :string
  end

  def self.down
    remove_column :teasers, :filter
  end
end
