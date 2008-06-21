class ContentMovie < ActiveRecord::Base
  has_many :asset_usages, :order => 'position', :as => :parent
  has_many :assets, :through => :asset_usages, :order => 'position'
end