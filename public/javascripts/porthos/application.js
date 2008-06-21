if (typeof LowPro != "undefined") {
  // Add iframe to LowPro element builders
  (function() {
	  window['$iframe'] = DOM.Builder.tagFunc('iframe');
  })();
}

if (typeof Porthos == "undefined") {
    var Porthos = {};
}
Porthos.namespace = function() {
  var a=arguments, o=null, i, j, d;
  for (i=0; i<a .length; i=i+1) {
    d = a[i].split(".");
    o = window;
    for (j=0; j<d.length; j=j+1) {
      o[d[j]]=o[d[j]] || {};
      o=o[d[j]];
    }
  }
  return o;
};

Porthos.extract_id = new RegExp(/([A-z]|\_|\-)*/i);
Porthos.extractId = function(string) {
  return string.replace(Porthos.extract_id,'');
};

Porthos.IframeObserver = Class.create(Abstract.TimedObserver, {
  getValue: function() {
    return this.getElement().innerHTML.unescapeHTML();
  },
  getElement: function() {
    var iframe = this.element.contentWindow ? this.element.contentWindow.document : this.element.contentDocument;
    return (iframe.documentElement || iframe.body);
  },    
  resetElement: function() {
    this.clearCallback();
    this.getElement().innerHTML = '';
  },
  registerCallback: function() {
    this.interval = setInterval(this.onTimerEvent.bind(this), this.frequency * 1000);
  },
  clearCallback: function() {
    clearInterval(this.interval);
  }
});

Porthos.namespace('Porthos.Helpers');
Porthos.Helpers.buttonTo = function(options) {
  var options = Object.extend({
    'method': 'get',
    'action': '',
    'class' : 'button_to',
    'name'  : 'Send'
  }, options);

  var button_options = {
    'type' : (!options['src']) ? 'submit' : 'image',
    'value': options['name'],
  };

  if (button_options['type'] == 'image') {
    button_options['src'] = options['src'];
  }


  var container = $div();
  if ($A(['put', 'delete']).include(options['method'])) {
    container.appendChild($input({
      'type' : 'hidden',
      'name' : '_method',
      'value': options['method']
    }));
  }

  button = $input(button_options);
  container.appendChild(button);
  if (options['confirm']) {
    button.onclick = function() {
      return confirm(options['confirm']);
    };
  }

  form_method = (options['method'] == 'get') ? 'get' : 'post';
  form = $form({
    'action': options['action'],
    'method': form_method,
    'class' : options['class']
  }, container);

  return form;
};

Porthos.Helpers.graphicLabel = function(element) {
  var labels = $A(element.getElementsByTagName('label'));
  labels.invoke('observe', 'click', function(event) {
    labels.invoke('removeClassName', 'checked');
    $(this).addClassName('checked');
  });
};

Porthos.Sorting = Class.create({
  initialize: function(el, list, serialized_name) {
    if($(el) == null) { return; }
    
    this.sorting = false;
    this.serialized_name = serialized_name || 'items'
    this.sorting_link = $(el);
    this.list = $(list);
    this.setup();
  },
  
  setup: function() {
    this.sorting_link.observe('click', function(ev){
      this.old_list_state = this.list.cloneNode(true);
      if(this.sorting == false) {
        Sortable.create(this.list, { handle: 'draghandle' });
        this.save_button = $input({ 'type': 'submit', 'value': 'Spara sortering', 'class': 'button' });
        this.cancel_link = $a({ 'href': '' }, 'Avbryt');
        this.cancel_link.observe('click', function(ev){
          this.list.replace(this.old_list_state);
          this.list = this.old_list_state;
          this.old_list_state = null;
          this.tearDown();
          Event.stop(ev);
        }.bind(this));
        form = $form({ 'action': this.sorting_link.href }, this.save_button, ' eller ', this.cancel_link );          
        Element.insert(this.sorting_link.parentNode, { after: $div({ 'class': 'confirm', 'id': 'save_sorting_container' }, form) });
        form.observe('submit', function(sort_event) {
          this.save();
          sort_event.stop();
        }.bind(this));     
        this.list.addClassName('sorting');
        this.sorting = true;
      }
      ev.stop();
    }.bind(this));
  },
  
  save: function() {      
    new Ajax.Request(this.sorting_link.href, {
      method: 'put',
      parameters: Sortable.serialize(this.list, {name: this.serialized_name}), 
      onComplete: function(response) {
        this.tearDown();
      }.bind(this)
    });
  },
  
  tearDown: function() {
    Sortable.destroy(this.list);
    $('save_sorting_container').remove();
    this.list.removeClassName('sorting');
	  this.sorting = false;
  }
});