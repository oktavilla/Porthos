class Admin::PaymentsController < ApplicationController
  include Porthos::Admin
  before_filter :login_required
  layout 'activities'
  
  def index
    per_page = params[:per_page] || 25
    @payments = Payment.paginate(:page => params[:page], :per_page => per_page.to_i, :order => 'created_at')
  end
  
  def show
    @payment = Payment.find()
  end
  
  def serach
    
  end
  
end