Porthos.AssetUsages = function(element, options) {
  return new Porthos.AssetUsages.Collection(element, options);
};

Porthos.AssetUsages.Collection = Class.create({
  asset_type: 'image_assets',
  initialize: function(element, options) {
    this.element = element;
    this.options = Object.extend({
      afterCreate: Prototype.emptyFunction
    }, options || {});
    this.form = this.element.getElementsBySelector('form.new_asset_usage').first();
    this.list = this.element.getElementsBySelector('ul.assets').first();
    this.controls = $li({ 'class': 'label' });
    Element.insert(this.list.parentNode, { after: this.controls });
    this.initAssetPicker();
    this.members = this.list.select('li').collect(function(element) {
      return new Porthos.AssetUsages.Member(element);
    });
    if (this.list.select('li').size() > 1) {
      sort_link = $a({ 'href':'#' }, 'Ändra ordning');
      sort_link.observe('click', function(ev) {
        this.setupSorting();
        Event.stop(ev);
      }.bind(this));
      this.controls.appendChild(document.createTextNode(' '));
      this.controls.appendChild(sort_link);
    }
    this.sorting = false;
  },
  
  assetPicker: function() {
    return this._asset_picker || this.initAssetPicker();
  },
  
  initAssetPicker: function() {
    link = $a({ 'href' : '#', 'class' : 'create' }, 'Lägg till en bild');
    this.controls.appendChild(link);
    this._asset_picker = new Porthos.Assets.Picker(this.asset_type, {
      callback: function(event) {
        asset = event.element();
        Porthos.Dialog().setWaitState();
        Porthos.AssetUsages.Member.create({
          'parent_id'  : this.form.elements['asset_usage[parent_id]'].value,
          'parent_type': this.form.elements['asset_usage[parent_type]'].value,
          'asset_id'   : Porthos.extractId(asset.id)
        }, function(response) {
          var member = new Porthos.AssetUsages.Member(null, response.responseText.evalJSON());
          this.push(member);
          Porthos.Dialog().clearWaitState();
          Porthos.Dialog('assets').hide();
          this.options.afterCreate();
        }.bind(this));
      }.bindAsEventListener(this)
    });
    link.observe('click', function(ev) {
      this.assetPicker().open(); 
      Event.stop(ev);
    }.bind(this));
    this.form.hide();
    return this._asset_picker;
  },
  
  // Sorting
  setupSorting: function() {
    if (this.sorting) { return false; }
    else { this.sorting = true; }
    this.old_list_state = this.list.cloneNode(true);
    Sortable.create(this.list, {
      constraint: false,
      overlap   : 'horizontal'
    });
    cancel = $a({ 'href': '' }, 'avbryt');
    form = $form(
      { 'action': Routes.sort_admin_asset_usages() },
      $input({ 'type': 'submit', 'value': 'Spara sortering', 'class': 'button' }),
      ' eller ',
      cancel
    );
    this.list.parentNode.insertBefore($div({ 'class': 'confirm' }, form), this.list);
    cancel.observe('click', function(ev) {
      this.tearDownSorting();
      this.list.replace(this.old_list_state);
      this.list = this.old_list_state;
      this.old_list_state = null;
      Event.stop(ev);
    }.bind(this));
    form.observe('submit', this.sort.bindAsEventListener(this));
    this.list.addClassName('sorting');
  },
  
  tearDownSorting: function() {
    this.sorting = false;
    Sortable.destroy(this.list);
    this.element.select('div.confirm').invoke('remove');
    this.list.removeClassName('sorting');
  },
  
  sort: function(event) {
    new Ajax.Request(Routes.sort_admin_asset_usages(), {
      method: 'put',
      parameters: Sortable.serialize(this.list, {
        name: 'asset_usages'
      }),
      onComplete:function() {
        this.tearDownSorting();
        new Effect.Highlight(this.list);
      }.bind(this)
    });
    event.stop();
  },
  
  push: function(member) {
    this.list.appendChild(member.element());
  }
});

Porthos.AssetUsages.Member = Class.create({
  initialize: function(element, json) {
    this._element = element;
    this.json = json;
    if (this._element) {
      this.setupObserves();
    }
  },
  
  setupObserves: function() {
    this.observeDestroy();
  },
  
  observeDestroy: function() {
    this.element().select('form').invoke('observe', 'submit', this.destroy.bindAsEventListener(this));
  },
  
  destroy: function(event) {
    new Ajax.Request(event.element().action, {
      method: 'delete',
      onComplete: function(response) {
        Porthos.Dialog().clearWaitState();
        new Effect.Fade(this.element());
      }.bind(this)
    });
    event.stop();
  },
  
  element: function() {
    return this._element || this.createElement();
  },
  
  createElement: function() {
    return this._createElement();
  },
  
  _createElement: function() {
    this._element = $li({
      'id': 'asset_usage_' + this.json.id
    });
    this._element.appendChild($img({
      'src': Routes.display_image('c80x80', this.json.asset.file_name, this.json.asset.extname),
      'alt': this.json.asset.title,
      'width' : 80,
      'height': 80
    }));
    this._element.appendChild(Porthos.Helpers.buttonTo({
      'action' : Routes.admin_asset_usage(this.json.id) + '?return_to=' + window.location,
      'method' : 'delete',
      'value'  : 'Radera',
      'src'    : '/graphics/porthos/icons/16_delete.png',
      'confirm': 'Är du helt säker?'
    }));
    return this._element;
  }
  
});
Porthos.AssetUsages.Member.create = function(data, callback) {
  new Ajax.Request(Routes.admin_asset_usages(), {
    method: 'post',
    parameters: $H(data).collect(function(value){
      return 'asset_usage['+value[0]+']='+value[1];
    }).join('&'),
    onComplete: callback
  });
};
