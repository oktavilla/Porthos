class RegistrationComment < ActiveRecord::Base
  belongs_to :registration
  belongs_to :user
    
  before_save :update_registration
  
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
end