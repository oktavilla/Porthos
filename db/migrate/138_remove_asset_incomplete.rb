# class UpdatePorthosTo138 < ActiveRecord::Migration
#   def self.up
#     migrate_plugin 'porthos', 138
#   end
# 
#   def self.down
#     migrate_plugin 'porthos', 137
#   end
# end

class RemoveAssetIncomplete < ActiveRecord::Migration
  def self.up
    remove_column :assets, :incomplete
  end

  def self.down
    add_column :assets, :incomplete, :boolean, :default => true
  end
end
