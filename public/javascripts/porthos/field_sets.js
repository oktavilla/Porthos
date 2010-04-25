document.observe('dom:loaded', function() {
  $$('#fields').each(function(table_body) {
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
});
