document.observe('dom:loaded', function() {
  var types_container = $('field_types');
  var type_specific_containers = $$('#field_form div.type');
  switch_field_type = function(field_type) {
    $$('#field_customizations div.type').each(function(type) {
      types_container.insert(type);
    })
    $('field_form').select('div.'+field_type.underscore()).each(function(type) {
      $('field_customizations').insert(type);
    });
  };
  $('field_type').observe('change', function(event) {
    switch_field_type($(this).getValue());
  });
  switch_field_type($('field_type').getValue());
});