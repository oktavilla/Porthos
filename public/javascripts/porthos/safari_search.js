Porthos.SearchField = Class.create({
  initialize: function(element) {
    this.element = $(element);
    this.transform();
  },
  
  transform: function() {
    input = $input({
      'type' :  'search',
      'class':  'query',
      'name' :  'query',
      'value':  this.element.value
    });
    
    input.old_value = input.value;
    input.observe('focus', function() {
      if (this.value == this.old_value) { this.value = ''; }
    });
    input.observe('blur', function() {
      if (this.value == '') { this.value = this.old_value; }
    });
    
    var new_el = Element.insert(this.element, {
      'before' : $div({ 'class': 'safarisearch' }, 
        $span({ 'class': 'sbox_l' }),
        $span({ 'class': 'sbox' }, input ),
        $span({ 'class': 'sbox_r' })
      )
    });
    new_el.next('input').remove();
    new_el.remove(this.element);
  }
});

Porthos.SearchField.find = function(element) {
  if (!(scope = ($(element) || $('wrapper')))) { return };
  scope.select('input.search').each(function(el) {
    new Porthos.SearchField(el);
  });
}

Event.onReady(function() {
  if (!Prototype.Browser.WebKit)
    Porthos.SearchField.find();
});