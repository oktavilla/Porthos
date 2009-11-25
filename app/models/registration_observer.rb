class RegistrationObserver < ActiveRecord::Observer
  
  def before_create(registration)
    if not registration.payable? and not registration.needs_confirmation?
      registration.status = 1 
    end
  end

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
  
  def before_update(registration)
    if registration.payable?
      if registration.payment_status == 'Failed' or registration.payment_status == 'Denied'
        registration.status = 3
      end
      if registration.paid?
        if not registration.needs_confirmation? 
          if not registration.respond_to?(:shipped?) or (registration.respond_to?(:shipped?) and registration.shipped?)
            registration.status = 1
          end
        end
      end
    end
  end
  
  def after_update(registration)
    # send confirmation and notification for the registrations that are payable
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
