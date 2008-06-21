class PaymentObserver < ActiveRecord::Observer
  def after_create(payment)
    if payment.payable.respond_to?(:print_settings) and payment.payable.print_settings.any?
      OrderMailer.deliver_print_settings(payment.payable)
    end
  end
end