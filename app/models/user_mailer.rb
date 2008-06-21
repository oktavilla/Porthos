class UserMailer < ActionMailer::Base
  def new_password(user)
    @recipients = user.email
    @from       = "do-not-replay@example.com"
    @subject    = "Dina användaruppgifter"
    body[:user] = user
  end
end