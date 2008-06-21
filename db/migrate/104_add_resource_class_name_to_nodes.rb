class AddResourceClassNameToNodes < ActiveRecord::Migration
  class Node < ActiveRecord::Base
  end
  def self.up
    add_column :nodes, :resource_class_name, :string
    Node.find_all_by_controller('page_collections').each do |node|
      node.update_attributes(:resource_class_name => 'PageCollection', :controller => 'pages')
    end
  end
  
  def self.down
    Node.find_all_by_resource_class_name('PageCollection').each do |node|
      node.update_attributes(:controller => 'page_collections')
    end
    remove_column :nodes, :resource_class_name
  end
end