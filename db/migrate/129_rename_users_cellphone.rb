class RenameUsersCellphone < ActiveRecord::Migration
  def self.up
    rename_column :users, :cellphone, :cell_phone
  end

  def self.down
    rename_column :users, :cell_phone, :cellphone
  end
end