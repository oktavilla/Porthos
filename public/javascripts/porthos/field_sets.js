document.observe('dom:loaded', function() {
  $$('tbody#field_sets').each(function(table_body) {
    Sortable.create(table_body, {
      ghosting:true,
      tag: 'tr',
      onUpdate: function() {
        new Ajax.Request(Routing.sort_admin_field_sets_path(), {
          method: 'put',
          parameters: Sortable.serialize(table_body, {
            name: 'field_sets'
          })
        });
      }
    });
  });

  $$('tbody#fields').each(function(table_body) {
    Sortable.create(table_body, {
      ghosting:true,
      tag: 'tr',
      onUpdate: function() {
        new Ajax.Request(Routing.sort_admin_field_set_fields_path({ 'field_set_id' : Porthos.extractId($(table_body).up('table').id) }), {
          method: 'put',
          parameters: Sortable.serialize(table_body, {
            name: 'fields'
          })
        });
      }
    });
  });
  $$('ul.items').each(function(table_body) {
    Sortable.create(table_body, {
      tag: 'li',
      onUpdate: function() {
        new Ajax.Request(Routing.sort_admin_pages_path(), {
          method: 'put',
          parameters: Sortable.serialize(table_body, {
            name: 'pages'
          })
        });
      }
    });
  });
});
