require File.dirname(__FILE__) + '/../test_helper'
require 'payments_controller'

# Re-raise errors caught by the controller.
class PaymentsController; def rescue_action(e) raise e end; end

class PaymentsControllerTest < Test::Unit::TestCase
  fixtures :payments, :registrations
  def setup
    @controller = PaymentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_new
    flunk "Not written"
  end

  def test_should_update
    donation = registrations(:private_donation_not_payed)
    put :update, :transaction_id => 123123, :reference_id => "abcdefghijklmnopqrstuvxyz", :response => 'A',  :message => "Approved", :amount => 10000
    assert assigns(:payable)
    assert assigns(:payment)
    assert_equal "123123", assigns(:payment).transaction_id, "The payment should have gotten the transaction_id"
    assert_equal "VerifyEasy_response:_OK", @response.body
    assert_response :success
  end
    
end
