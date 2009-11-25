(function(){
  Porthos.namespace('Porthos.Pages');

  Porthos.Pages.New = function() {
    Porthos.Editor.Initialize();
    $$('form#page.new').each(function(form) {
      form.select('div.graphic').each(function(element) {
        Porthos.Helpers.graphicLabel(element);
      });
    });
  };

  Porthos.Pages.Page = Class.create({
    initialize: function() {
      this.columns_container = $($$('div.page_layout')[0]);
      this.id       = Porthos.extractId(this.columns_container.id);
      this.columns  = this.columns_container.select('div.column').collect(function(div) {
        return {
          container: div,
          position : Porthos.extractId(div.id),
          element  : div.select('ul.contents')[0]
        }
      });
      this.contents = this.columns_container.select('ul.contents li.content').collect(function(element) {
        return Porthos.Pages.Contents.create(element);
      }.bind(this));
      this.contents.invoke('observeLinks');
      this.sorting = false;
      this.observeSortContents();
      // New contents
      this.columns_container.select('a.new_content').invoke('observe', 'click', function(event) {
        var link = event.element();
        new Ajax.Request(link.href, {
          method      : 'get',
          evalScripts : true,
          onLoading: function() {
            Porthos.Dialog().setWaitState();
            Porthos.Dialog().show();
          }.bind(this),
          onComplete: function(response) {
            Porthos.Dialog('page_contents').insert('new', response.responseText);
            Porthos.Pages.Contents.init(link);
            Porthos.Dialog('page_contents').get('new').select('form').invoke('observe', 'submit', function() {
              Porthos.Dialog().setWaitState();
            }.bind(this));
            Porthos.Dialog().clearWaitState();
          }.bind(this)
        });
        event.stop();
      }.bind(this));
      this.initializeDialogInvokers();
      $$('#content_header a.edit_page').invoke('observe', 'click', this.edit.bindAsEventListener(this));
    },
    
    edit: function(event) {
      new Ajax.Request(event.element().href, {
        method:'get',
        evalScripts: true,
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        }.bind(this),
        onComplete: function(response) {
          Porthos.Dialog('page').insert('edit', response.responseText);
          Porthos.Editor.Initialize();
          Porthos.Dialog().clearWaitState();
          $(Porthos.Dialog('page').get('edit')).select('div.graphic').each(function(element) {
            Porthos.Helpers.graphicLabel(element);
          });
          $(Porthos.Dialog('page').get('edit')).select('form').invoke('observe', 'submit', function(){
            Porthos.Dialog().setWaitState();
          }.bind(this));
          new Porthos.TagAutoCompletion($('page_tag_names'));
        }.bind(this)
      });
      event.stop();
    },
    
    initializeDialogInvokers: function() {
      this.columns.each(function(column) {
        column.container.select('a.add').invoke('observe', 'click', function(event) {
          element = event.element();
          if (!element.hasClassName('active')) {
            element.addClassName('active');
          } else {
            element.removeClassName('active');
          }
          column.container.select('div.sub_controls').invoke('toggle');
          event.stop();
        }.bind(this));
        // Asset pickers
        column.container.select('div.sub_controls a.image').invoke('observe', 'click', function(event) {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
          if (!this.asset_picker) {
            link = event.element();
            this.asset_picker = new Porthos.Assets.Picker('image_assets', {
              callback: function(event) {
                asset = event.element();
                new Ajax.Request(Routes.new_admin_page_content(this.id), {
                  method:'get',
                  parameters: $A([
                    link.href,
                    'resource[image_asset_id]=' + Porthos.extractId(asset.id)
                  ]).join('&'),
                  onLoading: function() {
                    Porthos.Dialog().setWaitState();
                  }.bind(this),
                  onComplete: function(response) {
                    Porthos.Dialog('page_contents').insert('new', response.responseText);
                    Porthos.Dialog().clearWaitState();
                  }.bind(this)
                });
              }.bind(this)
            });
            this.asset_picker.open();
          }
          event.stop();
        }.bind(this));
        column.container.select('div.sub_controls a.movie', 'li.sub_content a.movie').invoke('observe', 'click', function(event) {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
          if (!this.asset_picker) {
            link = event.element();
            is_collection = Porthos.parseUri(link.href).queryKey['collection'] == 1 ? 1 : 0;
            this.asset_picker = new Porthos.Assets.Picker('movie_assets', {
              callback: function(event) {
                asset = event.element();
                new Ajax.Request(Routing.new_admin_page_content_path({ page_id: this.id, collection: is_collection }), {
                  method:'get',
                  parameters: $A([
                    link.href,
                    'resource[movie_asset_id]=' + Porthos.extractId(asset.id)
                  ]).join('&'),
                  onLoading: function() {
                    Porthos.Dialog().setWaitState();
                  }.bind(this),
                  onComplete: function(response) {
                    Porthos.Dialog('page_contents').insert('new', response.responseText);
                    Porthos.Dialog().clearWaitState();
                  }.bind(this)
                });
              }.bind(this)
            });
            this.asset_picker.open();
          }
          event.stop();
        }.bind(this));
      }.bind(this));
    },
    
    observeSortContents: function() {
      $$('a.sort').invoke('observe', 'click', this.setupSorting.bindAsEventListener(this));
    },
    
    setupSorting: function(event) {
      if (this.sorting) { return false; }
      else { this.sorting = true; }
      this.sortables = this.columns_container.select('ul.sortable');
      this.teaserCollections = this.columns_container.select('ul.teasers');
      this.columns_container.addClassName('sorting');
      this.sortables.reverse().each(function(sortable) {
        sortable.isColumn = sortable.hasClassName('contents');
        if (!sortable.isColumn) {
          sortable.isTeaserContainer = sortable.hasClassName('teasers');
        }
        if (sortable.isColumn) {
          sortable_containment = this.columns.collect(function(column) { return column.element; });
          sortable.column = this.columns.detect(function(column) {
            return column.element == sortable;
          });
        } else if (sortable.isTeaserContainer) {
          sortable_containment = this.teaserCollections;
        } else {
          sortable_containment = sortable;
        }
        Sortable.create(sortable, {
          containment : sortable_containment,
          dropOnEmpty : true,
          hoverclass  : 'drop_target',
          scroll      : window,
          handle      : 'draghandle',
          only        : 'sortable',
          constraint  : false
        });
      }.bind(this));
      this.columns.each(function(column) {
        form = $form(
          { 'action': Routes.sort_admin_page_contents(this.id) },
          $input({ 'type': 'submit', 'value': 'Spara sortering', 'class': 'button' }),
          ' eller ',
          $a({ 'href': '' }, 'avbryt')
        );
        form.observe('submit', this.sort.bindAsEventListener(this));
        column.element.parentNode.insertBefore($div({ 'class': 'confirm' }, form), column.element);
        $(this.columns_container).select('span.controls, div.sub_controls').invoke('hide');
      }.bind(this));
      event.stop();
    },
    
    sort: function(event) {
      event.element().blur();
      this.sortables.each(function(sortable) {
        var params = '';
        if (sortable.isColumn) {
          params = '&column_position=' + encodeURIComponent(sortable.column.position);
        } else if (sortable.isTeaserContainer) {
          params = '&parent_id=' + encodeURIComponent(Porthos.extractId(sortable.id));
        }
        new Ajax.Request(Routes.sort_admin_page_contents(this.id), {
          method: 'put',
          parameters: Sortable.serialize(sortable, {
            name: 'contents'
          }) + params
        });
      }.bind(this));
      this.teardownSorting();
      event.stop();
    },
    
    teardownSorting: function(event) {
      this.sortables.each(function(sortable) {
        Sortable.destroy(sortable);
      });
      $(this.columns_container).select('div.confirm').invoke('remove');
      $(this.columns_container).select('span.controls').invoke('show');
      this.columns_container.removeClassName('sorting');
      this.sorting = false;
    }
  });

  Porthos.namespace('Porthos.Pages.Contents');
  Porthos.Pages.Contents.avalible_types = $A(['Teaser', 'Textfield']),
  
  Porthos.Pages.Contents.getObjectType = function(element) {
    return Porthos.Pages.Contents.avalible_types.detect(function(_type) {
      return element.className.indexOf(_type) != -1
    }) || 'Generic';
  };
  
  Porthos.Pages.Contents.create = function(element) {
    try {
      return eval('new Porthos.Pages.Contents.' + Porthos.Pages.Contents.getObjectType(element) + '(element);');
    } catch (e) {}
  };

  Porthos.Pages.Contents.init = function(element) {
    try {
      eval('Porthos.Pages.Contents.' + Porthos.Pages.Contents.getObjectType(element) + '.init()');
    } catch (e) {}
  };

  Porthos.Pages.Contents.Generic = Class.create({
    editCallback: Prototype.emptyFunction,
    initialize: function(element) {
      this.element = $(element);
    },
    
    observeLinks: function() {
      this.element.select('a.edit, a.settings').invoke('observe', 'click', this.edit.bindAsEventListener(this));
    },
    
    edit: function(event) {
      new Ajax.Request(event.element().href, {
        method: 'get',
        evalScripts: true,
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        }.bind(this),
        onComplete: function(response) {
          Porthos.Dialog('page_contents').insert('edit', response.responseText);
          Porthos.Dialog().clearWaitState();
          $(Porthos.Dialog('page_contents').get('edit')).select('form').invoke('observe', 'submit', function() {
            Porthos.Dialog().setWaitState();
          });
          this.editCallback(Porthos.Dialog('page_contents').get('edit'));
        }.bind(this)
      });
      event.stop();
    }
  });
  Porthos.Pages.Contents.Generic.init = function() {};
  
  Porthos.Pages.Contents.Textfield = Class.create(Porthos.Pages.Contents.Generic, {
    editCallback: function($super, element) {
      Porthos.Editor.Initialize();
    }
  });
  Porthos.Pages.Contents.Textfield.init = function() {
    Porthos.Editor.Initialize();
  };

  Object.extend(Porthos.AssetUsages.Member.prototype, {
    createElement: function() {
      this._createElement();
      this._element.appendChild($a({ 'href' : Routing.edit_admin_asset_usage_path(this.json.id) + '?return_to=' + window.location, 'class' : 'edit' }, 'Beskär'));
      this.setupObserves();
      return this._element;
    },
    
    setupObserves: function() {
      this.observeEdit();
      this.observeDestroy();
    },
    
    observeEdit: function() {
      this.element().select('a.edit').invoke('observe', 'click', this.edit.bindAsEventListener(this));
    },
    
    edit: function(event) {
      new Ajax.Request(event.element().href, {
        method: 'get',
        evalScripts: true,
        onLoading: function() {
          Porthos.Dialog().setWaitState();
          Porthos.Dialog().show();
        },
        onComplete: function(response) {
          Porthos.Dialog('asset_usages').insert('edit', response.responseText);
          Porthos.Dialog().clearWaitState();
          $(Porthos.Dialog('asset_usages').get('edit')).select('form').invoke('observe', 'submit', function(event) {
            var form = event.element();
            new Ajax.Request(form.action, {
              method: 'put',
              parameters: Form.serialize(form),
              onLoading: function() {
                Porthos.Dialog().setWaitState();
              },
              onComplete: function() {
                Porthos.Dialog('page_contents').show('edit');
                Porthos.Dialog().clearWaitState();
              }
            });
            event.stop();
          });
        }.bind(this)
      });
      event.stop();
    }
  });

  Porthos.Pages.Contents.Teaser = Class.create(Porthos.Pages.Contents.Generic, {
    editCallback: function($super, element) {
      Porthos.Editor.Initialize();
      this.assetUsages = new Porthos.AssetUsages.Collection($(element).select('div.asset_usages').first(), {
        afterCreate: function() {
          Porthos.Dialog('page_contents').show('edit');
        }
      });
      this.observeInputs();
    },
    
    observeInputs: function() {
      $$('div.graphic').each(function(div) {
        Porthos.Helpers.graphicLabel(div);
      });
    }
  });
  Porthos.Pages.Contents.Teaser.init = function() {
    teaser = new Porthos.Pages.Contents.Teaser(Porthos.Dialog('page_contents').get('new'));
    teaser.observeInputs();
    Porthos.Editor.Initialize();
  };

  Porthos.Pages.Contents.ContentMovie = Class.create(Porthos.Pages.Contents.Generic, {
    editCallback: function($super, element) {
    }
  });
  Porthos.Pages.Contents.ContentMovie.init = function() {
    this.asset_picker = new Porthos.Assets.Picker('movie_assets', {
      callback: function(event) {
        asset = event.element();
        new Ajax.Request(Routes.new_admin_page_content(this.id), {
          method:'get',
          parameters: $A([
            link.href,
            'resource[image_asset_id]=' + Porthos.extractId(asset.id)
          ]).join('&'),
          onLoading: function() {
            Porthos.Dialog().setWaitState();
          }.bind(this),
          onComplete: function(response) {
            Porthos.Dialog('page_contents').insert('new', response.responseText);
            Porthos.Dialog().clearWaitState();
          }.bind(this)
        });
      }.bind(this)
    });
    this.asset_picker.open();
    event.stop();
  };
  
  Event.onReady(function() {
    if ($$("body#pages.show").size() > 0) {
      var page = new Porthos.Pages.Page();
    } else if ($$("body#pages.new, body#pages.create").size() > 0) {
      var page = Porthos.Pages.New();
    }
  });
  
})();