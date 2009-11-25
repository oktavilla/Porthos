# == Schema Information
# Schema version: 76
#
# Table name: payments
#
#  id               :integer(11)   not null, primary key
#  payable_type     :string(255)   
#  payable_id       :integer(11)   
#  recurring        :boolean(1)    
#  billing_method   :string(255)   
#  transaction_id   :string(255)   
#  status           :string(255)   
#  response_message :string(255)   
#  amount           :integer(11)   default(0), not null
#  created_at       :datetime      
#  updated_at       :datetime      
#  result_code      :string(255)   
#

class Payment < ActiveRecord::Base
  
  attr_accessor :card_type, :card_number, :card_expiry_month, :card_expiry_year, :card_number_cvc
  attr_writer :first_name, :last_name
  
  belongs_to :payable, :polymorphic => true
 
  validates_presence_of :payable_id, :billing_method, :amount, :on => :create
  validates_presence_of :first_name, :last_name, :on => :create, :if => Proc.new { |payment| payment.creditcard_payment? }
  
  composed_of :amount, :class_name => "Money", :mapping => %w(amount cents) do |amount|
    amount.to_money
  end
  
  after_update :update_payable
  
  def first_name
    @first_name ||= payable.first_name
  end

  def last_name
    @last_name ||= payable.last_name
  end
  
  def paid?
    status == 'Completed'
  end
  
  def denied?
    status == 'Denied'
  end
  
  def failed?
    status == 'Failed'
  end
  
  def pending?
    status == 'Pending'
  end
  
  def in_progress?
    (!transaction_id.blank? && !denied? && !failed?) || pending?
  end
  
  def creditcard
    @creditcard ||= ActiveMerchant::Billing::CreditCard.new({
      :type               => card_type,
      :number             => card_number,
      :month              => card_expiry_month,
      :year               => card_expiry_year,
      :verification_value => card_number_cvc,
      :first_name         => first_name,
      :last_name          => last_name
    })
  end
  
  def card_type
    billing_method
  end
  
  def billing_type
    @billing_type ||= Payment.billing_type_for_payment_method(billing_method)
  end
  
  def creditcard_payment?
    self.class.creditcard_methods.include?(billing_type)
  end
  
  def direct_payment?
    self.class.direct_payment_methods.include?(billing_type)
  end
  
  def invoice_payment?
    billing_method == 'invoice'
  end

  def integration_url(integration_params = {})
    integration.service_url({
      :data             => payable.build_debitech_purchase,
      :referenceNo      => payable.public_id,
      :method           => billing_type,
      :currency         => 'SEK',
      :billingFirstName => "#{first_name} #{last_name}",
      :billingLastName  => payable.target_code,
      :billingAddress   => payable.address, 
      :billingCity      => payable.locality,
      :billingCountry   => 'Sweden',
      :eMail            => (!payable.email.blank? ? payable.email : 'dummy@dummy.com'),
      :pageSet          => (RAILS_ENV == "staging" ? "Unicef20Staging" : "Unicef20ShopDirect")
    }.merge(integration_params))
  end

  def authorize
    
    update_attribute(:status, 'Pending')
    
    payment_options = { 
      :billing_method => billing_type,
      :address        => (payable.shipping_address.blank?  ? payable.address  : payable.shipping_address), 
      :city           => (payable.shipping_locality.blank? ? payable.locality : payable.shipping_locality), 
      :email          => payable.email,
      :reference_id   => payable.public_id
    }
    
    if payable.respond_to?(:shipments) and not payable.shipment_price.zero?
      payment_options[:shipment]       = payable.shipment_price.round.cents
      payment_options[:shipment_type]  = payable.shipment_type
    end
    
    @authorize_response ||= gateway.authorize(creditcard, payable.build_debitech_purchase, payment_options)
    self.response_message = @authorize_response.message
    self.transaction_id   = @authorize_response.authorization
    self.result_code      = @authorize_response.params['result_code']
    self.status           = @authorize_response.success? ? 'Approved' : 'Denied'
    save
    @authorize_response
  end
  
  def settle
    @settle_response ||= gateway.settle(transaction_id, payable.public_id, amount.cents)
    self.response_message = @settle_response.message
    self.result_code      = @settle_response.params['result_code']
    self.status           = @settle_response.success? ? 'Completed' : 'Failed'
    @settle_response
  end

  def creditcard_type(method)
    self.class.creditcard_type(method)
  end

  class << self
    
    def for_payable(payable, *args)
      returning Payment.new(*args) do |payment|
        payment.payable         = payable
        payment.billing_method  = payable.payment_type
        payment.amount          = payable.total_amount_gross
      end
    end

    def creditcard_type(method)
      type = payment_methods.find { |m| m[:method] == method }
      type[:id] if type
    end
    
    def creditcard_methods
      ['cc.cekab', 'cc.nw']
    end
        
    def direct_payment_methods
      ['direct.nb', 'direct.sebp', 'direct.shb', 'direct.fsb']
    end
    
    def payment_methods
      [
        { :name => 'VISA',                :method => 'cc.cekab',    :id => 'visa' },
        { :name => 'MasterCard',          :method => 'cc.cekab',    :id => 'master' },
        { :name => 'American Express',    :method => 'cc.nw',       :id => 'american_express' },
        { :name => 'Nordea',              :method => 'direct.nb',   :id => 'nordea' },
        { :name => 'SEB (Privatkund)',    :method => 'direct.sebp', :id => 'seb' },
        { :name => 'Handelsbanken',       :method => 'direct.shb',  :id => 'hsb' },
        { :name => 'Swedbank',            :method => 'direct.fsb',  :id => 'swedbank' },
      ]
    end
    
    def billing_type_for_payment_method(payment_method)
      Payment.payment_methods.find { |m| m if m[:id] == payment_method }[:method] rescue false
    end
  end

protected  

  # def validate
  #   errors.add(:base, "Kreditkortsuppgifterna verkar inte vara giltiga. Kontrollera att de är rätt kortnummer och datum.") if creditcard_payment? and not creditcard.valid?
  # end

  def integration
    ActiveMerchant::Billing::Integrations::Debitech.shop = payable.sale? ? 'unicef' : 'unicef2'
    @integration ||= ActiveMerchant::Billing::Base.integration('debitech')
  end

  def gateway
    @gateway ||= ActiveMerchant::Billing::DebitechGateway.new(:url => (payable.sale? ? 'https://secure.incab.se:443/verify/server/unicef' : 'https://secure.incab.se:443/verify/server/unicef2'))
  end
  
  # after save
  def update_payable
    payable.update_attributes({
      :payment_status           => status,
      :payment_response_message => response_message,
      :payment_transaction_id   => transaction_id
    })
  end
  
end
