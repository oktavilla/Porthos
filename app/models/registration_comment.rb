class RegistrationComment < ActiveRecord::Base
  belongs_to :registration
  belongs_to :user
  has_and_belongs_to_many :payments
  
  attr_accessor :refunded_payments
  
  before_save :update_registration, :update_payments
  
  def humanized_status
    Registration::HUMANIZED_STATUSES[self.status]
  end
  
protected
  def update_registration
    if status != registration.status or fraud != registration.fraud
      self.updated_registration = true
      registration.status = status
      registration.fraud = fraud
      registration.save(false)
    end
  end
  
  def update_payments
    if refunded_payments and refunded_payments.any?
      refunded_payments.each do |payment_id, value|
        payment = Payment.find(payment_id)
        payment.update_attribute(:status, "Refunded")
        payments << payment
      end
    end
  end
end