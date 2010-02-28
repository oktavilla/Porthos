(function(){
  Porthos.namespace('Porthos.Nodes');

  Porthos.Nodes.init = function(element) {
    this.element = $(element);

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
      this.element.select('ul').reverse().each(function(list) {
        Sortable.destroy(list);
      });
    }
    
    this.setupSortables = function() {
      this.element.select('ul').reverse().each(function(list) {
        sortable($(list).identify());
      });
    }
    
    this.setupSortables();
    
    this.element.select('a.toggle_handle').invoke('observe', 'click', function(event) {
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
    }.bind(this));
  };

  document.observe('dom:loaded', function() {
    Porthos.Nodes.init('navigation');
  });
})();