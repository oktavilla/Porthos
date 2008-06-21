require File.dirname(__FILE__) + '/../test_helper'

class NodeTest < Test::Unit::TestCase
  fixtures :nodes

  def test_should_create
    assert_difference 'Node.count' do
      node = create_node
      assert !node.new_record?, "#{node.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    node = create_node :name => ""
    assert_not_nil node.errors.on(:name), "Should require a name"
  end

  def test_should_require_controller
    node = create_node :controller => ""
    assert_not_nil node.errors.on(:controller), "Should require a controller"
  end

  def test_should_not_accept_non_existant_controller
    node = create_node :controller => "nonexistantcontrollername"
    assert_not_nil node.errors.on(:controller), "Should require a real controller"
  end

  def test_should_require_action
    node = create_node :action => ""
    assert_not_nil node.errors.on(:action), "Should require a action"
  end

  def test_should_genereate_a_slug_from_the_name
    node = create_node(:name => 'My new node')
    assert_equal '/my-new-node', node.slug, "Should generate a slug from the name"
  end

  def test_should_update_children_if_the_slug_changes
    node = nodes(:projects)
    child = node.children.first
    node.name = 'Our Projects'
    node.save
    child.reload
    assert_equal child.slug, "/our-projects/#{child.name.to_url}", "Should have been updated with the parents name in the slug"
  end

  def test_should_default_status_to_hidden
    node = create_node
    assert node.hidden?, "Should default to hidden status but was: #{node.access_status}"
  end

private
  
  def create_node(options = {})
    Node.create({
      :name => 'News',
      :controller => 'application',
      :action => 'index'
    }.merge(options))
  end
    
end
