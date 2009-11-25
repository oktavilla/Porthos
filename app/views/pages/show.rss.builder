xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@page.title)
    xml.link(root_url)
    xml.language('sv-SV')
    @pages.each do |page|
      year, month, day = page.published_on.beginning_of_day.strftime("%Y"), page.published_on.beginning_of_day.strftime("%m"), page.published_on.beginning_of_day.strftime("%d")
      xml.item do
        xml.title(page.title)
        xml.description(page.main_content_column.blank? ? page.description : render_page_contents_for_rss(page.contents.active.find(:all, :conditions => ["column_position = ? AND (resource_type = ? OR resource_type = ?)", page.main_content_column, 'Textfield', 'ContentImage'])))
        xml.pubDate(page.published_on.strftime_without_localization("%a, %d %b %Y %H:%M:%S %z"))
        xml.link("#{root_url}#{@page.node.slug}/#{year}/#{month}/#{day}/#{page.slug}")
      end
    end
  }
}
