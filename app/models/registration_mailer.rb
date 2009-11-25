class RegistrationMailer < ActionMailer::Base
  def confirmation(registration) 
    @subject    = registration.email_subject
    @body       = registration.parsed_email_body(:registration => registration.attributes, :node => registration.node.attributes)
    @recipients = registration.email
    if registration.replyable_email?
      @from = registration.reply_to_email.blank? ? registration.contact_person.email : registration.reply_to_email
    else
      @from = 'no.reply@example.com'
    end
    @sent_on    = registration.created_at

    registration.confirmation_attachments.each do |email_attachment|
      attachment email_attachment.mime_type do |a|
        a.body     = File.read(email_attachment.path)
        a.filename = email_attachment.file_name
      end
    end if registration.respond_to?(:confirmation_attachments) and registration.confirmation_attachments.any?
  end
  
  def notification(registration)
    @subject    = "#{registration.class.localized_model_name} registrering"
    @body       = { :registration => registration }
    @recipients = registration.notification_person.email
    @from       = 'no.reply@example.com'
    @sent_on    = registration.created_at
  end
end
