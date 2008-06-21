xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0") {
  xml.channel {
    xml.title("UNICEF Sverige | #{@node.name}")
    xml.link("#{request.protocol}#{request.domain}/#{@node.slug}.rss")
    xml.description(@page.description)
    xml.language('sv')
      @pages.each do |page|
        xml.item do
          xml.title(page.title)
          xml.description(page.description)
          xml.pubDate(page.published_on.strftime("%a, %d %b %Y %H:%M:%S %z"))
          year, month, day = page.published_on.strftime("%Y"), page.published_on.strftime("%m"), page.published_on.strftime("%d")
          xml.link("#{request.protocol}#{request.domain}/#{@node.slug }/#{year}/#{month}/#{day}/#{page.slug}")
          xml.guid("#{request.protocol}#{request.domain}/#{@node.slug }/#{year}/#{month}/#{day}/#{page.slug}")
        end
      end
  }
}