require File.dirname(__FILE__) + '/../test_helper'
require 'measure_points_controller'

# Re-raise errors caught by the controller.
class MeasurePointsController; def rescue_action(e) raise e end; end

class MeasurePointsControllerTest < Test::Unit::TestCase
  fixtures :measure_points

  def setup
    @controller = MeasurePointsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:measure_points)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_measure_point
    assert_difference('MeasurePoint.count') do
      post :create, :measure_point => { }
    end

    assert_redirected_to measure_point_path(assigns(:measure_point))
  end

  def test_should_show_measure_point
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_measure_point
    put :update, :id => 1, :measure_point => { }
    assert_redirected_to measure_point_path(assigns(:measure_point))
  end

  def test_should_destroy_measure_point
    assert_difference('MeasurePoint.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to measure_points_path
  end
end
