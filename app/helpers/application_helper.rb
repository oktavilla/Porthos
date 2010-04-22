# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def nested_list_of(collection, options = {}, html_options = {}, &block)
    options = {
      :expand_all     => false,
      :allow_inactive => false,
      :first_level    => true,
      :node_cycle_values => ['odd', 'even'],
      :node_cycle_name   => 'nested_list_of',
      :node_class     => collection.first.class.to_s.underscore,
      :end_points     => [],
      :trail          => [],
      :except         => []
    }.merge(options)
    
    html_options = {
      :id => collection.first.class.to_s.underscore.pluralize
    }.merge(html_options)
    
    first_level = options.delete(:first_level)
    if first_level
      if options[:end_points]
        options[:end_points] = [options[:end_points]] unless options[:end_points].is_a?(Array)
        options[:end_points].collect { |item| options[:trail] += (item.ancestors << item) }
      end
    end
    html_options.delete(:id) unless first_level
    
    reset_cycle('nested_list_of_cycle') if first_level
    
    ret = collection.collect do |item|
      next if (item.respond_to?(:access_status) and item.access_status == 'inactive') and not options[:allow_inactive] == true
      next if item == options[:except] || (options[:except].respond_to?(:include?) && options[:except].include?(item))
      in_trail = options[:trail].include?(item)
      rendered_item = capture(item, &block)
      if (options[:expand_all] and item.children.any?) or ( in_trail and item.children.any? )
        rendered_item += nested_list_of(item.children, options.merge({ :first_level => false }), &block)
      end
      if item.respond_to?(:access_status)
        status_class = unless in_trail
          item.access_status
        else
          "#{item.access_status} trailed"
        end
      end
      options[:node_cycle_values].push({ :name => options[:node_cycle_name] })
      node_container_options = {
        :class => [
          awesome_cycle(options[:node_cycle_values].shift, options[:node_cycle_values]),
          options[:node_class],
          status_class
        ].join(" ")
      }
      if options[:node_id].nil?
        node_container_options[:id] = "#{item.class.to_s.underscore}_#{item.id}"
      elsif not options[:node_id].blank?
        node_container_options[:id] = "#{options[:node_id]}_#{item.id}"
      end
      
      content_tag('li', rendered_item, node_container_options)
    end.join("\n")
    
    list = content_tag('ul', ret, html_options)
    first_level ? concat(list) : list
  end
  
  def block_to_partial(partial_name, options = {}, &block)
    options.merge!(:body => capture(&block))
    concat(render(:partial => partial_name, :locals => options))
  end
  
  def toolbox(type, options = {}, &block)
    options = { :css_class => "" }.merge(options)
    block_to_partial 'admin/shared/toolbox', options, &block
  end
  
  def page_id
    @page_id ||= controller.class.to_s.underscore.gsub(/_controller$/, '').gsub(/admin\//, '')
    ' id="'+@page_id+'_view"'
  end
  
  def public_page_id
    @page_id ||= controller.class.to_s.underscore.gsub(/_controller$/, '').gsub(/admin\//, '')+'-'+controller.action_name.underscore
    ' id="'+@page_id+'"'
  end

  def page_class(css_class = false)
    body_class = []
    body_class << css_class   if css_class
    body_class << @page_class if @page_class
    body_class << controller.action_name.underscore
    if RAILS_ENV == 'development'
      body_class << 'debug' if params[:debug]
      body_class << 'grid' if params[:grid]
    end
    ' class="'+body_class.join(" ")+'"' if body_class.size > 0
  end
  
  def body_attributes
    page_id + page_class
  end
  
  def public_body_attributes
    public_page_id + page_class
  end

  def flash_messages(type = "")
    if type.blank?
      flash.collect do |type, message|
        content_tag('p', message, :class => "flash #{type}")
      end.join("\n")
    elsif flash[type.to_sym]
      content_tag('p', flash[type.to_sym], :class => "flash #{type}")
    end
  end

  def display_indicator(options = {})
    options[:display] ||= "none"
    html_options = options.dup
    html_options.delete(:display)
    html_options.delete(:message)
    html_options[:style]   ||= "display: #{options[:display]};"
    html_options[:id]      ||= 'indicator'
    html_options[:src]     ||= '/graphics/porthos/icons/indicator.gif'
    ret  = image_tag(html_options[:src])
    ret += "&nbsp;#{ options[:message] }" unless options[:message].nil?
    content_tag('span', ret, {:class => "indicator"}.merge(html_options))
  end
  
  # Just like the regular button_to helper but accepts an :src as html_options making it an type=image
  def button_to(name, options = {}, html_options = {})
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))
  
    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end
  
    form_method = method.to_s == 'get' ? 'get' : 'post'
  
    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    if confirm = html_options.delete("confirm")
      html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
    end
  
    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url
  
    type = html_options["src"].nil? ? "submit" : "image"
    html_options.merge!("type" => type, "value" => name)
    
    "<form method=\"#{form_method}\" action=\"#{escape_once url}\" class=\"button_to\"><div>" + 
      method_tag + tag("input", html_options) + request_token_tag + "</div></form>"
  end

  # Awesome truncate
  # First regex truncates to the length, plus the rest of that word, if any.
  # Second regex removes any trailing whitespace or punctuation (except ;).
  # Unlike the regular truncate method, this avoids the problem with cutting
  # in the middle of an entity ex.: truncate("this &amp; that",9)  => "this &am..."
  # though it will not be the exact length.
  def awesome_truncate(text, length = 30, truncate_string = "...")
    return if text.nil?
    l = length - truncate_string.mb_chars.length
    text.mb_chars.length > length ? text[/\A.{#{l}}\w*\;?/m][/.*[\w\;]/m] + truncate_string : text
  end 
  
  def flash_mediaplayer_tag(asset, options = {})
   options.merge!( {
     :file => display_movie_path(asset, asset.extname), 
     :image => (display_image_path(:size => asset.thumbnail.width, :id => asset.thumbnail, :format => asset.thumbnail.extname) if asset.movie?)
    })
    content = content_tag('a', t(:flash_is_needed, :scope => [:app, :general]), { :href => 'http://www.macromedia.com/go/getflashplayer'})
    content << options.collect { |option, value| content_tag('span', value, {:class => option}) }.join
    content_tag('div', content, { :class => 'mediaplayer', :id => "asset-#{asset.id}" })
  end


  # options
  # :start_date, sets the time to measure against, defaults to now
  # :date_format, used with <tt>to_formatted_s<tt>, default to :default
  def time_ago(time, options = {})
    start_date = options.delete(:start_date) || Time.new
    date_format = options.delete(:date_format) || :short
    delta_minutes = (start_date.to_i - time.to_i).floor / 60
    if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
      distance = distance_of_time_in_words(delta_minutes);
      if delta_minutes < 0
        "om #{distance}"
      else
        "#{distance} sen"
      end
    else
      return "på #{time.to_formatted_s(date_format)}"
    end
  end

  def distance_of_time_in_words(minutes)
    case
    when minutes < 1
      "mindre än en minut"
    when minutes < 50
      "#{minutes} minuter"
    when minutes < 90
      "ungefär en timme"
    when minutes < 1080
      "#{(minutes / 60).round} timmar"
    when minutes < 1440
      "en dag"
    when minutes < 2880
      "ungefär en dag"
    else
      "#{(minutes / 1440).round} dagar"
    end
  end
   
  def javascript_include_extensions
    js_file = "admin/#{controller.controller_name}"
    path = File.join(RAILS_ROOT, 'public/javascripts', "#{js_file}.js")
    javascript_include_tag(js_file) if File.exists?(path)
  end
  
  def installation_specific_stylesheet_link_tag
    path = File.join(RAILS_ROOT, 'public/stylesheets/porthos_extensions.css')
    stylesheet_link_tag(js_file) if File.exists?(path)
  end
  
  def flash_tag_for_asset(asset, options = {})
    options = { :max_width => 800 }.merge(options.symbolize_keys)
    width, height = if asset.width > options[:max_width]
      scale_factor = (options[:max_width].to_f  / asset.width.to_f)
      [(asset.width*scale_factor).to_i, (asset.height*scale_factor).to_i]
    else
      [asset.width, asset.height]
    end
    tag("embed", { :width => width, :height => height, :quality => "high", :src => "/swf/#{asset.full_name}", :type => "application/x-shockwave-flash" })
  end
  
  def render_page_contents_for_rss(contents, &block)
    capture do
      contents.collect do |content|
        render(:partial => "/pages/contents/#{content.resource_type.underscore}.html.erb", :locals => { :resource => content.resource, :page => @page, :content => content }) 
      end.join
    end
  end
  
  def admin_assets_path_with_session_key(arguments = {})
    session_key = ActionController::Base.session_options[:key]
    admin_assets_path({session_key => cookies[session_key], request_forgery_protection_token => form_authenticity_token}.merge(arguments))
  end
  
  def render_page_content(page, content, options = {})
    options = {
      :full_render => false
    }.merge(options)
    if options[:full_render] and (!content.restricted? || content.viewable_by(current_user))
      render(:partial => content.public_template, :locals => {
        :page     => page,
        :content  => content,
        :resource => content.resource,
        :full_render => options[:full_render]
      })
    elsif !options[:full_render] and !content.restricted?
      unless content.pre_renderable?
        "<"+"%= render(:partial => '#{content.public_template}', :locals => { :page => @page, :content => Content.find(#{content.id}), :resource => Content.find(#{content.id}).resource }) %"+">"
      else
        render(:partial => content.public_template, :locals => {
          :page     => page,
          :content  => content,
          :resource => content.resource,
          :full_render => options[:full_render]
        })
      end
    end
  end
  
  def form_field_for_custom_field(page, form_builder, field)
    string = ''
    string += "<label for=\"page_custom_field_#{field.id}\">#{field.label}</label>"
    string += "<p class=\"form_help\">#{field.instructions}</p>" unless field.instructions.blank?
    partial = "admin/fields/#{field.class.to_s.underscore}_form"
    string += begin
      render(:partial => partial, :locals => { :page => page, :builder => form_builder, :field => field })
    rescue ActionView::MissingTemplate
      ''
    end
    string
  end
  
  def display_image_path(options = {})
    if options.delete(:add_token) or not logged_in? or (logged_in? and not current_user.admin?)
      asset = options[:id].is_a?(Numeric) ? Asset.find(options[:id]) : options[:id]
      options[:token] = asset.resize_token(options[:size]) if options[:size]
    end
    resized_image_path(options)
  end
end
