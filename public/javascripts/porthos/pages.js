(function(){
  Porthos.namespace('Porthos.Pages');
  Porthos.Helpers.cloneAsUrl('page_title', 'page_slug');

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

      }.bind(this));
      this.setupSorting();
    },
     
    setupSorting: function() {
      this.sortables = this.columns_container.select('ul.sortable');
      this.teaserCollections = this.columns_container.select('ul.teasers');
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
          onUpdate    : this.sort.bindAsEventListener(this)
        });
      }.bind(this));
    },
    
    sort: function(event) {
      this.sortables.each(function(sortable) {
        var params = '';
        if (sortable.isColumn) {
          params = '&column_position=' + encodeURIComponent(sortable.column.position);
        } else if (sortable.isTeaserContainer) {
          params = '&parent_id=' + encodeURIComponent(Porthos.extractId(sortable.id));
        }
        new Ajax.Request(Routing.sort_admin_contents_path(), {
          method: 'put',
          parameters: Sortable.serialize(sortable, {
            name: 'contents'
          }) + params
        });
      }.bind(this));
    }
  });


  document.observe('dom:loaded', function() {
    $$('#filters_order_by_submit').invoke('hide');
    $$('#filters_order_by').invoke('observe', 'change', function(event) {
      this.form.submit();
    });
    
    if ($$("body#pages_view.show").size() > 0) {
      new Porthos.TagAutoCompletion($('page_tag_names'));
      $$('textarea.editor').each(function(el){
        Porthos.jQuery(el).wymeditor(Porthos.Editor.Options);
      });

      $$('#content div.edit a, #content a.cancel').invoke('observe', 'click', function(event) {
        var element = $(event.element());
        if (!(element.hasClassName('change')
          || element.hasClassName('add')
          || element.hasClassName('cancel'))) { return; }
        event.stop();
        var parent  = $(element.up('div.page_content'));
            query   = 'form';
        if (!parent.hasClassName('one_to_many')) {
          query += ', div.container';
        }
        parent.select(query).invoke('toggle');
      });
      
      $$('#page_publish_on_date a').invoke('observe', 'click', function(event) {
        event.stop();
        $$('#page_current_publish_on_date, #page_published_on_form').invoke('toggle');
      });

      $$('#page_tags a').invoke('observe', 'click', function(event) {
        event.stop();
        $$('#page_tags_list, #page_tags_form').invoke('toggle');
      });

      $$('#workspace > div.header').invoke('observe', 'click', function(event) {
        var element = $(event.element());
        if (element.nodeName.toUpperCase() != 'A' || !element.hasClassName('toggler')) {
          return;
        }
        event.stop()
        $$('#workspace > div.header').invoke('toggle');
      });

      $$('#content ul.sortable').each(function(element) {
        var sortable = $(element);
        Sortable.create(sortable, {
          onUpdate    : function(event) {
            new Ajax.Request(Routing.sort_admin_custom_associations_path(), {
              method: 'put',
              parameters: Sortable.serialize(sortable, {
                name: 'custom_associations'
              })
            });
          }
        });
      });

      var page = new Porthos.Pages.Page();
    }
    
  });
  
})();
