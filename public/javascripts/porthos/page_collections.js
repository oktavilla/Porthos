(function(){
  Porthos.namespace('Porthos.PageCollections');
  Porthos.PageCollections.Page = Class.create({
    initialize: function(element) {
      this.element = element;
      this.element.select('div.page').each(function(element) {
        new Porthos.PageCollections.Child(element);
      });
    },

    edit: function(event) {
      new Ajax.Request(event.element().href, {
				method:'get',
				parameters: { 'return_to': window.location },
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        }.bind(this),
        onComplete: function(response) {
          Porthos.Dialog('page').insert('edit', response.responseText);
          Porthos.Editor.Initialize();
          Porthos.Dialog().clearWaitState();
          $(Porthos.Dialog('page').get('edit')).select('form').invoke('observe', 'submit', function(){
            Porthos.Dialog().setWaitState();
          }.bind(this));
        }.bind(this)
      });
      event.stop();
    },

  });
  Porthos.PageCollections.Child = Class.create({
    initialize: function(element) {
      this.element = element;
    },
    
    edit: function(event) {
      new Ajax.Request(event.element().href, {
        method: 'get',
				parameters: { 'return_to': window.location },
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        },
        onComplete: function(response) {
          Porthos.Dialog('page').insert('edit', response.responseText);
          Porthos.Dialog().clearWaitState();
          Porthos.Editor.Initialize();
        }
      });
      event.stop();
    }
  });
	Event.onReady(function() {
	  new Porthos.PageCollections.Page($('container'));
    $$('span.controls a.create').invoke('observe', 'click', function(event) {
      new Ajax.Request(event.element().href, {
        method: 'get',
        onLoading: function() {
          Porthos.Dialog().show();
          Porthos.Dialog().setWaitState();
        },
        onComplete: function(response) {
					Porthos.Dialog('page').insert('new', response.responseText);
          Porthos.Editor.Initialize();
          Porthos.Dialog().clearWaitState();
          new Porthos.TagAutoCompletion($('page_tag_names'));
        }
      });
      event.stop();
    });
	});

})();
