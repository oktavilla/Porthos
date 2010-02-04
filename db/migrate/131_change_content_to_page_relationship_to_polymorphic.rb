class ChangeContentToPageRelationshipToPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :contents, :page_id, :context_id
    add_column :contents, :context_type, :string
    Content.connection.update("UPDATE contents SET context_type = 'Page'")
  end

  def self.down
    rename_column :contents, :context_id, :page_id
    remove_column :contents, :context_type
  end
end