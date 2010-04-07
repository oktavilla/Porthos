class NodeObserver < ActiveRecord::Observer

  def after_create(node)
    Porthos::Routing::Nodes.add(node, true)
    Node.logger.info("Added route for #{node.name}") 
  end
  
  def after_update(node)
    if node.slug_changed?
      Porthos::Routing::Nodes.update(node, true) 
      Node.logger.info("Updated route for #{node.name}") 
    else
      Node.logger.info("Skipped update of route for #{node.name} (no need)") 
    end
  end
  
  def after_destroy(node)
    Porthos::Routing::Nodes.remove(node, true)
    Node.logger.info("Removed route for #{node.name}") 
  end

end
