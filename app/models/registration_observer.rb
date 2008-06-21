class RegistrationObserver < ActiveRecord::Observer
  def after_create(registration)
    if not registration.payable?
      if registration.registration_form and registration.send_email_response?
        RegistrationMailer.deliver_confirmation(registration) rescue false
      end

      if registration.registration_form and registration.notification_person
        RegistrationMailer.deliver_notification(registration) rescue false
      end
    end
  end
  
  def after_update(registration)
    # send confirmation and notification for the registartions that are payable
    if registration.payable? and registration.paid?
      if registration.registration_form and registration.send_email_response?
        RegistrationMailer.deliver_confirmation(registration) rescue false
      end

      if registration.registration_form and registration.notification_person
        RegistrationMailer.deliver_notification(registration) rescue false
      end
    end
  end
  
end
