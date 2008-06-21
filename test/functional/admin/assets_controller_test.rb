require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/assets_controller'

# Re-raise errors caught by the controller.
class Admin::AssetsController; def rescue_action(e) raise e end; end

class Admin::AssetsControllerTest < Test::Unit::TestCase
  fixtures :assets, :taggings, :tags
  def setup
    @controller = Admin::AssetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as    :quentin
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:assets)
    assert assigns(:tags)
  end
  
  def test_should_get_index_with_tags
    get :index, { :tags => ['test'] }
    assert_response :success
    assert assigns(:assets)
    assert assigns(:tags)
    assert_equal 2, assigns(:assets).size, "Should have found 2 assets"
  end
  
  def test_should_create_asset
    old_count = Asset.count
    post :create, :files => [fixture_file_upload('files/alien.jpg', 'image/jpeg'), fixture_file_upload('files/fatty.jpg', 'image/jpeg') ]
    assert_equal old_count+2, Asset.count
    assert_redirected_to incomplete_admin_assets_url
  end
  
  def test_should_get_edit
    get :edit, :id => 'MyString'
    assert_response :success
    assert assigns(:asset)
    assert_select "form[action*=?]", admin_asset_path(assigns(:asset)) do
      assert_select "input[type=hidden][name=_method][value=put]"
    end
  end
  
  def test_should_update
    put :update, :id => 'MyString', :asset=> { :title => 'new name', :description => 'new description' }
    assert assigns(:asset)
    assert_redirected_to admin_assets_path
  end
  
  def test_should_update_multipble
    put :update_multiple, :assets => [[1,{:title => 'new name', :description => 'new description'}],[2,{:title => 'test 2', :tag_names => 'test, test-2'}]]
    assert_equal Asset.find(1).title, 'new name', 'Should have updated asset'
    assert_equal Asset.find(2).title, 'test 2', 'Should have updated asset'
    assert_equal Asset.find(2).tag_names, 'test, test-2', 'Should have updated asset'
    assert_redirected_to admin_assets_path
  end
  
end
