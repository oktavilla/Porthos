module Porthos
  module Public

    def self.included(base)
      base.send :include, Porthos::AccessControl
      base.send :include, ClassMethods
    end

    module ClassMethods
      # we should overwrite login_required to render a public login view
      def require_node
        @node ||= Node.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound

        @root = Node.root
        @root_nodes = [@root] + @root.children

        ancestors = @node.ancestors.reverse
        ancestors.shift
        # fetch an ordered trail (top to bottom) of nodes
        @trail = if ancestors and ancestors.any?
          ancestors << @node
        else
          [@node]
        end

        login_required if @trail.detect { |node| node.restricted? } and not logged_in?

        @breadcrumbs = @trail.collect { |node| ["/#{node.slug}", node.name] }

        # fetch the children of the selected top level node (it later recursive renders all nodes belonging to the trail)
        @nodes = unless @node == @root # dont fetch children for the root node (that's all nodes dummy!)
          ancestors.any? ? ancestors.first.children : @node.children
        else
          []
        end
      end
    end
  end
end