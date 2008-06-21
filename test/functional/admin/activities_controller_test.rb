require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/activities_controller'

# Re-raise errors caught by the controller.
class Admin::ActivitiesController; def rescue_action(e) raise e end; end

class Admin::ActivitiesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
