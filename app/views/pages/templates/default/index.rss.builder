xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0"){
  xml.channel{
    xml.title(@field_set.title)
    xml.link(root_url)
    xml.language('sv-SV')
    @pages.each do |page|
      year, month, day = page.published_on.beginning_of_day.strftime("%Y"), page.published_on.beginning_of_day.strftime("%m"), page.published_on.beginning_of_day.strftime("%d")
      xml.item do
        xml.title(page.title)
        xml.description(page.description)
        xml.pubDate(page.published_on.strftime("%a, %d %b %Y %H:%M:%S %z"))
        xml.link("#{root_url}#{@node.slug}/#{year}/#{month}/#{day}/#{page.slug}")
      end
    end
  }
}
