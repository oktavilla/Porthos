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
      content_tag('li', content_tag('a', link[:name], {
        :href => admin_assets_path(:type => link[:class])
      }), {
        :class => "#{options[:current].to_s == link[:class] ? 'current' : ''}"
      })
    end
  end
end
