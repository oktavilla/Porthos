module Admin::NodesHelper
  def node_path(node)
    url_for(:controller => node.controller, :action => node.action, :id => node.resource_id, :slug => node.slug)
  end
end
