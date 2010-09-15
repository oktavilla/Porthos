document.observe('dom:loaded', function() {
  // Payment status checkbox on registrations#show
  var payment_status_form = $('update_payment_status');
  if (payment_status_form) {
    $('submit_payment_status').hide();
    $('registration_payment_status').observe('click', function(event) {
      new Ajax.Request(payment_status_form.action, {
        method: 'put',
        parameters: payment_status_form.serialize()
      });

      var payment_status = $('payment_status');
      
      if (this.checked) {
        payment_status.removeClassName('pending');
        payment_status.addClassName('completed');
      } else {
        payment_status.removeClassName('completed');
        payment_status.addClassName('pending');
      }

      $(this).up('label').toggleClassName('paid');
    });
  }
});
