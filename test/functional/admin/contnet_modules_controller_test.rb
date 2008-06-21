require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/contnet_modules_controller'

# Re-raise errors caught by the controller.
class Admin::ContnetModulesController; def rescue_action(e) raise e end; end

class Admin::ContnetModulesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ContnetModulesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
