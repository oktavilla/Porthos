class MoveImageResourcesToAssetUsages < ActiveRecord::Migration
  class AssetUsage < ActiveRecord::Base; end
  class ImageResource < ActiveRecord::Base; end
  def self.up
    rename_column :asset_usages, :resource_id, :parent_id
    rename_column :asset_usages, :resource_type, :parent_type
    ImageResource.find(:all).each do |image_resource|
      AssetUsage.create({
        :asset_id    => image_resource.image_asset_id,
        :parent_id   => image_resource.parent_id,
        :parent_type => image_resource.parent_type,
        :created_at  => image_resource.created_at,
        :updated_at  => image_resource.updated_at,
        :position    => image_resource.position
      })
    end
    drop_table :image_resources
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
