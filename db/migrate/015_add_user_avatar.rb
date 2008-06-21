class AddUserAvatar < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_id, :integer
    add_index :users, :avatar_id
  end

  def self.down
    remove_column :users, :avatar_id
  end
end
