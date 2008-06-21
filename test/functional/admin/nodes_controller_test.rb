require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/nodes_controller'

# Re-raise errors caught by the controller.
class Admin::NodesController; def rescue_action(e) raise e end; end

class Admin::NodesControllerTest < Test::Unit::TestCase
  fixtures :nodes
  
  def setup
    @controller = Admin::NodesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as    :quentin
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:nodes)
  end

  def test_should_get_index_with_a_open_node
    get :index, { :nodes => [1] }
    assert_response :success
    assert assigns(:nodes)
    assert assigns(:open_nodes)
    assert_select "#nodes_tree>li>ul"
  end
  
  def test_should_redirect_on_show
    get :show, :id => 1
    assert assigns(:node)
    assert_redirected_to admin_nodes_path(:nodes => assigns(:node))
  end
  
  def test_should_get_place_node_view
    get :place, :id => 2
    assert_redirected_to admin_nodes_path
    assert assigns(:nodes)
    assert assigns(:node)
    assert !assigns(:nodes).include?(assigns(:node))
  end
  
  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
    assert assigns(:node)
    assert_select "form[action=?]", admin_node_path(assigns(:node)) do
      assert_select "input[type=hidden][name=_method][value=put]"
    end
  end
  
  def test_should_update
    put :update, :id => 1, :node => { :name => "New name", :status => -1 }
    assert assigns(:node)
    assert_redirected_to admin_nodes_path(:nodes => assigns(:node))
  end
  
  def test_should_handle_errors_on_update
    put :update, :id => 1, :node => { :name => "" }
    assert assigns(:node)
    assert_response :success
    assert_template 'edit'
    assert_select "#errorExplanation"
  end

  def test_should_destroy
    delete :destroy, :id => 1
    assert assigns(:node)
    assert_redirected_to admin_nodes_path
  end

end
