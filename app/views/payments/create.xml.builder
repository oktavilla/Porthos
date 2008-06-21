xml.instruct! :xml, :version => "1.0"
xml.payment {
  if @creditcard.valid?
    xml.status(@payment.status)
  else
    xml.status('Invalid')
  end
}