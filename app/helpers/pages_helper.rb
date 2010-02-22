module PagesHelper
  
  def render_page_content(page, content, options = {})
    options = {
      :full_render => false
    }.merge(options)
    if !options[:full_render] || (!content.restricted? || content.viewable_by(current_user))
      unless content.module?
        render(:partial => content.public_template, :locals => {
          :page     => page,
          :content  => content,
          :resource => content.resource,
          :full_render => options[:full_render]
        })
      else
        "<"+"%= render(:partial => #{content.public_template}, :locals => { :page => @page, :content => Content.find(#{content.id}) }) %"+">"
      end
    end
  end
  
end