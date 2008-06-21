class VirtualGiftsController < ApplicationController
  include VirtualGifts
  layout 'public'
  def show
    @vg_categories = VgCategory.active.find(:all, :order => 'position')
    @vg_category   = VgCategory.active.find(params[:vg_category_id])
    @virtual_gift  = @vg_category.virtual_gifts.find(params[:id])

    @node  = Node.find_by_slug(params[:slug]) or raise ActiveRecord::RecordNotFound
    @root  = Node.root
    @nodes = [@root] + @root.children

    ancestors = @node.ancestors.reverse
    # remove the root node
    ancestors.shift
    # fetch an ordered trail (top to bottom) of nodes
    @trail     = ancestors.any? ? ancestors << @node : [@node]
    # fetch the children of the selected top level node (it later recursive renders all nodes belonging to the trail)
    @sub_nodes = unless @node == @root # dont fetch children for the root node (that's all nodes dummy!)
      ancestors.any? ? ancestors.first.children : @node.children
    else
      []
    end

    @page_class = 'layout5'
    
    respond_to do |format|
      format.html
    end
  end

end
