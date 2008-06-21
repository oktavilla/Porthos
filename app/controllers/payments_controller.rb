require 'registration_methods'
require 'distribution_center'

class PaymentsController < ApplicationController
  include RegistrationMethods
  include SslRequirement

  before_filter Proc.new { |c| DistributionCenter::Base.mode = :send_test if RAILS_ENV == "development" or RAILS_ENV == "staging" }
  before_filter :find_payable, :except => :update
  
  def new
  end

  def create
    @payment.update_attributes(params[:payment])
    @creditcard = @payment.creditcard
    if @payment.valid? and @creditcard.valid?
      @payment_response = @payment.authorize
      @payment_response = @payment.settle if @payment_response.success?
      @payment.save!
    else
      flash[:payment_notice] = "Kreditkortsuppgifterna verkar inte vara giltiga. Kontrollera att det är rätt kortnummer och datum och att CVC koden stämmer."
      @failed = true
    end
    @return_path = session[:registration_return_path]
    respond_to do |format|
      if not @failed and @payment_response.success?
        if @payable.sale?
          @payable.reload
          @payable.deliver
        end
        format.html { session[:registration_return_path] = nil }
        format.xml { render :layout => false, :status => :created }
      else
        @failed = true
        format.html { render :action => :new }
        format.xml { render :layout => false, :status => (@creditcard.valid? ? 200 : 422) }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :action => :new }
      format.xml { render :xml => @payment.errors.to_xml, :status => 422 }
    end
  end
  
  def update
    # TODO: Add ensure clause so that we always notify debitech we got the report
    @payable = Registration.find_by_public_id(params[:reference_id]) or raise ActiveRecord::RecordNotFound
    @payment = @payable.payment

    notification = @payment.integration.notification(request.raw_post)
    @payment.update_attributes({
      :status           => notification.status,
      :response_message => notification.message,
      :transaction_id   => notification.transaction_id
    })
    @payable.reload
    @payable.deliver if notification.approved? and @payable.sale?

    respond_to do |format|
      format.html { render :text => notification.acknowledge_response }
    end
  end
  
protected
  def find_payable
    check_for_injected_params
    @payable = Registration.find(session[:current_registration])
    @payment = !@payable.payment ? Payment.for_payable(@payable, params[:payment]) : @payable.payment
  end

  def check_for_injected_params
    return unless params[:payment]
    approved_keys = [
      'first_name',
      'last_name',
      'card_number',
      'card_expiry_month',
      'card_expiry_year',
      'card_number_cvc',
      'card_type'
    ]
    params[:payment].stringify_keys.keys.each do |key|
      raise SecurityTransgression unless approved_keys.include?(key)
    end
  end
end
