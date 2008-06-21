(function(){
  Porthos.namespace('Porthos.Forms');
  
  Porthos.Forms.Dialog = Porthos.ActionDialog.Dialog();
  
  Porthos.Forms.Form = Class.create();
  Porthos.Forms.Form.prototype = {
    initialize: function(){
      if($('no_page_notice')){
        $('no_page_notice').observe('click', function(ev){
          Porthos.Forms.Dialog.show();
          Porthos.Forms.Dialog.setWaitState();
  				Porthos.Forms.Dialog.insertContent('new_thanks_page', $('new_page_container').down());
          Porthos.Forms.Dialog.clearWaitState();
          Event.stop(ev);
        });
      }
    }
  };
  
  Event.onReady(function() {
    var forms = new Porthos.Forms.Form();
  });
})();
