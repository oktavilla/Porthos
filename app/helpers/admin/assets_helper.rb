module Admin::AssetsHelper
  def asset_filter_links(options = {})
    options = {
      :current => 'Asset'
    }.merge(options.symbolize_keys!)
    asset_links = [
      { :name => 'Alla filer', :class => 'Asset' },
      { :name => 'Bilder',     :class => 'ImageAsset' },
      { :name => 'Filmer',     :class => 'MovieAsset' },
      { :name => 'Ljud',       :class => 'SoundAsset' }
    ]
    asset_links.collect do |link|
      if options[:current].to_s != link[:class]
        content_tag('a', link[:name], :href => admin_assets_path(:type => link[:class]))
      else
        content_tag('span', link[:name], { :class => 'current' })
      end
    end
  end
end
