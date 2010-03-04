(function(){
  Porthos.nodes = function(element, options) {
    this.element = $(element);
    this.options = Object.extend({
      sortable : true
    }, options || {});
    sortable = function(element) {
      Sortable.create(element, {
        containment: element,
        onUpdate: function(list) {
          new Ajax.Request(Routing.sort_admin_nodes_path(), {
            method: 'put',
            parameters: Sortable.serialize(list, { name : 'nodes' })
          });
        }
      });
    };
    
    this.destroySortables = function() {
      if (!this.options.sortable) { return; }
      this.element.select('ul').reverse().each(function(list) {
        Sortable.destroy(list);
      });
    };
    
    this.setupSortables = function() {
      if (!this.options.sortable) { return; }
      this.element.select('ul').reverse().each(function(list) {
        sortable($(list).identify());
      });
    };
    
    if (this.options.sortable) {
      this.setupSortables();
    }
    
    this.observeToggle = function(event) {
      event.stop();

      var handle = event.element();

      parent = function() {
        return handle.up('li', 0);
      };

      children = function() {
        var _children = this._children = parent().down('ul', 0);
        return ((typeof _children != 'undefined') ? _children : false);
      };

      switch(handle.textContent.strip()) {
        case '+':
          handle.update('-');
          if (!children()) {
            new Ajax.Request(handle.href, {
              method:'get',
              evalScripts: false,
              onComplete: function(response) {
                var parent = handle.up('li', 0);
                parent.insert({ 'bottom' : response.responseText });
                this.destroySortables();
                this.setupSortables();
                children().select('a.toggle_handle').invoke('observe', 'click', this.observeToggle.bindAsEventListener(this));
              }.bind(this)
            });
          } else {
            children().show()
          }
          break;
        case '-':
          handle.update('+');
          children().hide();
          break;
      }
    };
    
    this.element.select('a.toggle_handle')
    .invoke('observe', 'click', this.observeToggle.bindAsEventListener(this));
  };
  
  document.observe('dom:loaded', function() {
    Porthos.nodes('navigation');
  });
})();