module Admin::AssetsHelper
  def asset_filter_links(filters)
    asset_links = [
      { :name => 'Bilder',     :class => 'ImageAsset' },
      { :name => 'Video',     :class => 'VideoAsset' },
      { :name => 'Ljud',       :class => 'SoundAsset' }
    ].collect do |link|
      content_tag('li', content_tag('a', link[:name], {
        :href => admin_assets_path(:filters => filters.merge(:by_type => link[:class]))
      }), {
        :class => "#{filters[:by_type] == link[:class] ? 'current' : ''}"
      })
    end
    asset_links.unshift(content_tag('li', content_tag('a', 'Alla filer', {
      :href => admin_assets_path(:filters => filters.except(:by_type))
    }), {
      :class => (filters[:by_type].nil? ? 'current' : '')
    }))
  end
end
