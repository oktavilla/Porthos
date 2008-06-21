(function(){
  Porthos.namespace('Porthos.Pages');
  
  
  Porthos.Pages.Presets = Class.create();
  Porthos.Pages.Presets.prototype = {
    initialize: function() {
      this.dialog   = Porthos.ActionDialog.Dialog();
      this.contents = 
      $('new_page').observe('click', this.show_presets.bindAsEventListener(this));
    },
    
    show_presets: function(ev) {
      this.dialog.setWaitState();
      this.dialog.insertContent('presets_form', $('page_presets').innerHTML);
      this.dialog.show();
      this.setup_events();
      this.dialog.clearWaitState();
      return false;
    },
    
    setup_events: function() {
      this.preset_buttons = $(this.dialog.contents['presets_form']).getElementsBySelector('.preset_radio');
      this.export_mode_container = $(this.dialog.contents['presets_form']).getElementsBySelector('#expert_mode').first();
      this.preset_buttons.invoke('observe', 'click', function(ev){
        clicked_radio = Event.element(ev);
        this.preset_buttons.each(function(el) { 
          if(el.checked == false) {
            if(el.up('li')) { el.up('li').removeClassName('active'); }
          }else{  
            if(el.up('li')) { el.up('li').addClassName('active'); }
          }
        });
        (clicked_radio.id == 'toggle_export_mode') ? this.export_mode_container.show() : this.export_mode_container.hide();
      }.bind(this));
    }
  }
  
  Event.onReady(function() {
	  var page_presets = new Porthos.Pages.Presets();
	});
})();