class AddStiToContents < ActiveRecord::Migration
  def self.up
    add_column :contents, :parent_id, :integer
    add_column :contents, :type, :string
    add_column :contents, :accepting_content_resource_type, :string
    add_index :contents, :parent_id
  end

  def self.down
    remove_column :contents, :parent_id
    remove_column :contents, :type
  end
end
