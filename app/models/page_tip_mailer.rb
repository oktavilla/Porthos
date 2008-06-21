class PageTipMailer < ActionMailer::Base
  def tip(page_tip)
    @subject    = "#{page_tip.name} vill tipsa dig om en sida på UNICEF Sveriges webbplats"
    @body       = {:page_tip => page_tip}
    @recipients = page_tip.recipients.split(' ')
    @from       = 'no.reply@unicef.se'
  end
end
