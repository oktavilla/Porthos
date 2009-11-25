(function(){
  Porthos.namespace('Porthos.Nodes');
  
  Porthos.Nodes.Collection = {
    nodes: [],
    _each: function(iterator) {
      this.nodes._each(iterator);
    },
    
    register: function(node) {
      if (!this.include(node)) {
        this.nodes.push(node);
      }
    },
    
    empty: function() {
      this.nodes = [];
    },
    
    openNodes: function() {
      return this.findAll(function(node) {
        return node.isOpen();
      });
    }
  };
  Object.extend(Porthos.Nodes.Collection, Enumerable);

  Porthos.Nodes.Node = Class.create({
    children: $A(),
    initialize: function(element){
      if (!(this.element  = $(element))) { return false; };
      this.toggle_handle = this.element.getElementsBySelector('a.toggle_handle')[0] || false;
      this.open = false;
      if (!(this.collection = this.element.childElements().find(function(child) { return child.tagName.toLowerCase() == 'ul' }))) {
        this.fetched_children = false;
        this.collection = this.element.appendChild($ul({ 'class':'placeholder' }));
      } else {
        this.fetched_children = true;
      }
      if (this.toggle_handle) {
        this.toggle_handle.observe('click', this.toggleChildren.bindAsEventListener(this));
      }
      
      this.element.getElementsBySelector('> a.settings').invoke('observe', 'click', this.edit.bindAsEventListener(this));
      
      this.loadChildren();
      Porthos.Nodes.Collection.register(this);
    },
    
    edit: function(ev) {
      new Ajax.Request(Event.element(ev).href, {
        method: 'get',
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        },
        onComplete: function(response) {
          Porthos.Dialog('node').insert('edit', response.responseText);
          Porthos.Dialog().clearWaitState();
        }
      });
      Event.stop(ev);
    },
    
    isOpen:function() {
      if (this.toggle_handle) {
        return this.toggle_handle.hasClassName('active');
      } else {
        return false;
      }
    },
    
    loadChildren:function() {
      this.collection.getElementsBySelector('li.node').each(function(element) {
        new Porthos.Nodes.Node(element);
      });
    },
    
    showCollection:function(ev) {
      if (this.fetched_children) {
        this.collection.show();
      } else {
        link = Event.element(ev);
        new Ajax.Request(link.href, {
          method:'get',
          evalScripts:false,
          onComplete:this.insertChildren.bind(this)
        });
       }
      this.toggle_handle.addClassName('active');
    },
    
    insertChildren:function(response) {
      this.collection.removeClassName('placeholder');
      this.collection.insert(response.responseText);
      this.collection.show();
      this.fetched_children = true;
      this.loadChildren();
    },
    
    hideCollection:function(ev) {
      this.collection.hide();
      this.toggle_handle.removeClassName('active');
    },
    
    toggleChildren:function(ev) {
      if (this.isOpen()) {
        this.hideCollection(ev);
      } else {
        this.showCollection(ev);
      }
      Event.stop(ev);
    }
  });

  Porthos.Nodes.Tree = Class.create({
    initialize: function(element) {
      this.root_nodes = $A(),
      this.element    = $(element);
      this.loadNodes();
      this.sorting = false;
    },
    
    loadNodes: function() {
      Porthos.Nodes.Collection.empty();
      $$('#'+this.element.id+' > li.node').each(function(element) {
        Porthos.Nodes.Collection.register(new Porthos.Nodes.Node(element));
      });
    },
    
    resetNodeSorting:function(){
      $('toggle_node_sorting').stopObserving('click', this.cached_sorting_listener);
      Sortable.destroy('nodes_tree');
      Sortable.create('nodes_tree', {
        tree: true,
        handle: 'handle'
      });
      this.setUpNodeSorting();
    },
    
    setupSorting:function() {
      this.element.addClassName('sorting');
      Sortable.create(this.element, {
        tree:        true,
        hoverclass:  'hover',
        dropOnEmpty: true,
        ghosting: true,
        // FIXME: Slow and stupid
        onUpdate: function(container) {
          $A(container.getElementsByTagName('ul')).each(function(ul) {
            if ($(ul).childElements().size() != 0) {
              $(ul).removeClassName('placeholder');
            } else if (!$(ul).hasClassName('placeholder')) {
              $(ul).addClassName('placeholder');
            }
          });
        }
      });
      this.sorting = true;
    },

    sort: function() {
      open_string = Porthos.Nodes.Collection.openNodes().collect(function(node) {
        return encodeURIComponent("open_nodes[]")+'='+encodeURIComponent(Porthos.extractId(node.element.id));
      }).join('&');
      new Ajax.Request(Routes.sort_admin_nodes(), {
        method: 'put',
        parameters: Sortable.serialize(this.element)+'&'+open_string,
        onComplete: function(response) {
          this.teardownSorting();
          Element.replace(this.element.innerHTML, response.responseText);
          this.element = $(this.element.id); // refetch the element
          this.loadNodes();
        }.bind(this)
      });
    },
    
    teardownSorting: function() {
      Sortable.destroy(this.element);
      this.element.removeClassName('sorting');
      this.sorting = false;
    }
  });

  Event.onReady(function() {
    var root  = new Porthos.Nodes.Node('root');
    var nodes = new Porthos.Nodes.Tree('nodes');
    $$('span.controls a.sort').invoke('observe', 'click', function(ev) {
      if (!nodes.sorting) {
        nodes.setupSorting();
        form = $form({ 'action': Routes.sort_admin_nodes() },
          $input({ 'type': 'submit', 'value': 'Spara sortering', 'class': 'button' }),
          ' eller ',
          $a({ 'href': '' }, 'Avbryt'));

        Element.insert(this.parentNode, { after: $div({ 'class': 'confirm' }, form) });

        form.observe('submit', function(sort_event) {
          nodes.sort();
          $$('#container div.confirm').invoke('remove');
          sort_event.stop();
        });
      }
      Event.stop(ev);
    });
    $$('span.controls a.create').invoke('observe', 'click', function(ev) {
      new Ajax.Request(Event.element(ev).href, {
        method: 'get',
        onLoading: function() {
          Porthos.Dialog().show();
          Porthos.Dialog().setWaitState();
        },
        onComplete: function(response) {
          Porthos.Dialog('page').insert('new', response.responseText);
          $$('form#page.new').each(function(form) {
            form.select('div.graphic').each(function(element) {
              Porthos.Helpers.graphicLabel(element);
            });
          });
          Porthos.Dialog().clearWaitState();
        }
      });
      Event.stop(ev);
    });
  });
})();