class ContentMovie < ActiveRecord::Base
  include Porthos::ContentResource

  belongs_to :asset, :class_name => 'MovieAsset', :foreign_key => 'movie_asset_id'
end