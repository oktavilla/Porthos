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
  
  Porthos.Pages.Edit = function() {
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
      this.contents = this.columns_container.select('ul.contents li.content').collect(function(element) {
//        return Porthos.Pages.Contents.create(element);
      }.bind(this));
//      this.contents.invoke('observeLinks');
      this.sorting = false;
      this.observeSortContents();
      // New contents
      
      this.initializeDialogInvokers();
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
          { 'action': Routing.sort_admin_contents_path() },
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
        new Ajax.Request(Routing.sort_admin_contents_path(), {
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
      var publish_link = $a({
        'href' : Routing.publish_admin_page_path({ 'id' : this.id })
      }, 'Publicera ändringarna');
      publish_link.observe('click', function(event) {
        event.stop();
        var link = event.element();
        var f = $form({
          'action' : link.href,
          'method' : 'post',
          'style'  : 'display:none;'
        }, $input({
          'type'  : 'hidden',
          'name'  : '_method',
          'value' : 'put'
        }));
        link.parentNode.appendChild(f);
        f.submit();
      });
      if ($$('p.notice').size() == 0) {
        this.columns_container.insert({
          'top' : $p({ 'class' : 'notice' }, publish_link)
        });
      }
      this.sorting = false;
    }
  });
  
  Event.onReady(function() {
    if ($$("body#pages.show").size() > 0) {
      var page = new Porthos.Pages.Page();
    } else if ($$("body#pages.new, body#pages.create").size() > 0) {
      var page = Porthos.Pages.New();
    } else if ($$("body#pages.edit").size() > 0) {
      var page = Porthos.Pages.Edit();
    }
  });
  
})();