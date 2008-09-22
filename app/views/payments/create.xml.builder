xml.instruct! :xml, :version => "1.0"
xml.payment {
if @creditcard.valid?
  if @payment.denied?
    xml.status('Declined')
  elsif @payment.paid?
    xml.status('Approved')
  else
    xml.status('Invalid')
  end
else
  xml.status('Invalid')
end
}