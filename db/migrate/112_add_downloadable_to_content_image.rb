class AddDownloadableToContentImage < ActiveRecord::Migration
  def self.up
    add_column :content_images, :downloadable, :boolean, :default => false
  end

  def self.down
    remove_column :content_images, :downloadable
  end
end
