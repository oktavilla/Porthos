class AddHandleToFieldSets < ActiveRecord::Migration

  def self.up
    add_column :field_sets, :handle, :string
    add_index :field_sets, :handle
  end

  def self.down
    remove_column :field_sets, :handle
  end

end