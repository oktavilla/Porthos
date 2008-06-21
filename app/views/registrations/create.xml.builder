xml.instruct! :xml, :version=>"1.0"
xml.registration {
  xml.public_id(@registration.public_id)
  xml.bank_url(@redirection_url) if @payment and @payment.direct_payment?
}