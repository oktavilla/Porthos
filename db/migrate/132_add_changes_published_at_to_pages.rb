class AddChangesPublishedAtToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :rendered_body, :text
    add_column :pages, :changed_at, :datetime
    add_column :pages, :changes_published_at, :datetime
  end

  def self.down
    remove_column :pages, :rendered_body
    remove_column :pages, :changed_at
    remove_column :pages, :changes_published_at
  end
end