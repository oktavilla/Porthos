File.open(File.join(RAILS_ROOT, 'public', 'javascripts', 'routes.js'), 'w') do |file|
  file <<"var Routes = {\n"
  ActionController::Routing::Routes.named_routes.routes.each do |name, route|
    dynamic_segments = route.segments.select { |s| s.respond_to?(:key) }
    route.segments.pop
    file <<"  #{name}: function(#{dynamic_segments.map(&:key).join(', ')}) {\n"
    file <<"    return '" + route.segments.collect { |segment| segment.respond_to?(:key) ? "'+#{segment.key}+'" : segment.to_s }.join()
    file <<"';\n"
    file <<"  },\n\n"
  end
  file <<"};"
end
