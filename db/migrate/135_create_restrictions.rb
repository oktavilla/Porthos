class CreateRestrictions < ActiveRecord::Migration

  def self.up
    create_table :restrictions do |t|
      t.integer     :content_id
      t.string      :mapping_key
      t.timestamps
    end
    add_index :restrictions, :content_id
    add_column :contents, :restrictions_count, :integer
  end

  def self.down
    drop_table :restrictions
    remove_column :contents, :restrictions_count
  end

end