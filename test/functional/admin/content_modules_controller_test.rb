require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/content_modules_controller'

# Re-raise errors caught by the controller.
class Admin::ContentModulesController; def rescue_action(e) raise e end; end

class Admin::ContentModulesControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ContentModulesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
