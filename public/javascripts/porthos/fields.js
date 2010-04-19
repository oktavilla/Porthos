document.observe('dom:loaded', function() {
  var type_specific_containers = $$('#field_form div.type');
  switch_field_type = function(field_type) {
    type_specific_containers.invoke('hide');
    $('field_form').select('div.'+field_type.underscore()).invoke('show');
  };
  $('field_type').observe('change', function(event) {
    switch_field_type($(this).getValue());
  });
  switch_field_type($('field_type').getValue());
});