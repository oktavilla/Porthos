(function(){
  Porthos.namespace('Porthos.Pages');

  Porthos.Pages.SetupForm = function() {
    new Porthos.TagAutoCompletion($('page_tag_names'));
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
          constraint  : false,
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
  
  Event.onReady(function() {
    if ($$("body#pages.show").size() > 0) {
      var page = new Porthos.Pages.Page();
    } else if ($$("body#pages.new, body#pages.edit").size() > 0) {
      var page = Porthos.Pages.SetupForm();
    }
  });
  
})();