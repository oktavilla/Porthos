Porthos.namespace('Porthos.Assets');

Porthos.Assets.Asset = Class.create({
  initialize: function(attributes) {
    this.attributes = attributes || {};
  },
  
  landscape: function() {
    return this.attributes.width > this.attributes.height;
  },

  portrait: function() {
    return !this.landscape();
  },

  widthForHeight: function(height) {
    if (height > this.attributes.height) {
      return this.attributes.width;
    }
    return Math.ceil(this.attributes.width * (height / this.attributes.height));
  },
  
  heightForWidth: function(width) {
    if (width > this.attributes.width) {
      return this.attributes.height;
    }
    return Math.ceil(this.attributes.height * (width / this.attributes.width));
  },
  
  createElement: function() {
    if (this.attributes.type == 'ImageAsset') {
      if (this.landscape()) {
        img = $img({
          'src'   : Routes.display_image('c87x87', this.attributes.file_name, this.attributes.extname),
          'alt'   : this.attributes.title,
          'width' : 87,
          'height': 87
        });
      } else {
        img = $img({
          'src'   : Routes.display_image('c87x87', this.attributes.file_name, this.attributes.extname),
          'alt'   : this.attributes.title,
          'width' : 84,
          'height': 87
        });
      }
    } else if (this.attributes.type == 'MovieAsset') {
      img = $img({
        'src'   : Routes.display_image('c87x87', this.attributes.thumbnail.file_name, this.attributes.thumbnail.extname),
        'alt'   : this.attributes.title,
        'width' : 87,
        'height': 87
      });
    } else {
      img = $span({'class': 'icon '+this.attributes.extname});
    }
    var element = $li({ 'class': 'asset', 'id': 'asset_' + this.attributes.id }, img);
    meta = $div({'class': 'meta'});
    element.appendChild(meta);
    meta.appendChild($span({
        'class': 'title'
      },
      'Titel: ',
      $span({'class':'value'}, this.attributes.title)
    ));
    // TODO: format the date somehow (can't use Date.parse() with this format)
    meta.appendChild($span({
        'class': 'created_at'
      },
      'Uppladdad: ',
      $span({'class':'value'}, this.attributes.created_at)
    ));
    meta.appendChild($span({
        'class': 'file_name'
      },
      'Filnamn: ',
      $span({'class':'value'}, this.attributes.file_name)
    ));
    return element;
  }
});

Porthos.Assets.Uploader = Class.create({
  initialize: function(form, options) {
    if (!(this.form = $(form))) { return; }
    this.form.action += '.js';
    this.options = Object.extend({
      timer: 0.5
    }, options || {});
    this.onLoading  = options.onLoading || Prototype.emptyFunction;
    this.onComplete = function(element, value) {
      (options.onComplete || Prototype.emptyFunction).apply(this, arguments);
      this.resetElement();
    };
    this.target = this.createUploadTarget();
    this.form.parentNode.appendChild(this.target);
    this.form.observe('submit', this.submit.bindAsEventListener(this));
  },
  
  createUploadTarget: function() {
    identifier = 'asset_upload_target';
    return $iframe({
      'id'   : identifier,
      'name' : identifier,
      'src'  : '',
      'class': identifier,
      'style': 'width: 0; height: 0; border: none; visibility: hidden;'
    });
  },
  
  submit: function(event) {
    this.form.target = this.target.id;
    this.onLoading(event);
    new Porthos.IframeObserver(this.target, this.options.timer, this.onComplete);
  }
});

Porthos.Assets.Picker = Class.create({
  // Extend the callback per instance
  initialize: function(assets_type, options) {
    this.assets_type = assets_type || 'assets';
    this.options = Object.extend({
      callback: Prototype.emptyFunction
    }, options || {});
  },
  
  open: function() {
    this.findAssets();
    return false;
  },
  
  close: function() {
    Porthos.Dialog().hide();
  },
  
  findAssets: function(url) {
    new Ajax.Request(url || Routes.admin_assets()+'?type='+this.assets_type+'&per_page=24', {
      method: 'get',
      onLoading: function() {
        Porthos.Dialog().setWaitState();
      }.bind(this),
      onComplete: function(response) {
        if (Porthos.Dialog().sessions.size() > 0) {
          Porthos.Dialog().current().hide();
        }
        Porthos.Dialog('assets').insert('show', response.responseText);
        Porthos.Dialog().clearWaitState();
        this.observeAssets('show');
        this.observeSearchBox('show');
        Porthos.SearchField.find(Porthos.Dialog('assets').get('show'));
        new Porthos.Assets.Uploader('upload_asset_form', {
          timer: 0.2,
          onLoading:function() {
            Porthos.Dialog().setWaitState();
          },
          onComplete: function(element, value) {
            new_assets = $A(value.evalJSON()).collect(function(object) {
              return new Porthos.Assets.Asset(object);
            });
            if (new_assets.size() == 1) {
              new_asset = new_assets.first();
              new Ajax.Request(Routes.formatted_edit_admin_asset(new_asset.attributes.file_name, 'js'), {
                method: 'get',
                evalScripts: true,
                onComplete: function(response) {
                  Porthos.Dialog('assets').insert('edit', response.responseText);
                  Porthos.Dialog().clearWaitState();
                  $(Porthos.Dialog('assets').get('edit')).select('form').invoke('observe', 'submit', function(event) {
                    new Ajax.Request(event.element().action, {
                      method: 'put',
                      parameters: Form.serialize(event.element()),
                      onLoading: function() {
                        Porthos.Dialog().setWaitState();
                      },
                      onComplete: function(response) {
                        new_asset = new Porthos.Assets.Asset(response.responseText.evalJSON());
                        parent = $(Porthos.Dialog('assets').get('show').select('ul.assets')[0]);
                        Porthos.Dialog().current().hide();
                        Porthos.Dialog('assets').show('show');
                        this.appendAsset(new_asset, parent);
                        Porthos.Dialog().clearWaitState();
                      }.bind(this)
                    });
                    event.stop();
                  }.bind(this));
                  Porthos.Dialog().clearWaitState();
                }.bind(this)
              });
            } else {
              parent = $(Porthos.Dialog('assets').get('show').select('ul.assets')[0]);
              new_assets.each(function(asset) {
                this.appendAsset(asset, parent);
              }.bind(this));
              Porthos.Dialog().clearWaitState();
            }
          }.bind(this)
        });
      }.bind(this)
    });
  },
  
  appendAsset: function(asset, parent) {
    first_sibling = parent.firstDescendant();
    element = asset.createElement();
    parent.insertBefore(element, first_sibling);
    this.observeAsset(element);
    this.positionAssetsMeta(element);
  },
  
  observeSearchBox: function(content) {
    $(Porthos.Dialog('assets').get(content)).select('form.search_assets').invoke('observe', 'submit', this.search.bindAsEventListener(this));
  },
  
  observeAssets: function(content) {
    assets = Porthos.Dialog('assets').get(content).select('li.asset');
    assets.each(function(asset) {
      this.observeAsset(asset);
    }.bind(this));
    // make the meta data align correctly
    this.positionAssetsMeta(Porthos.Dialog('assets').get(content));
    $(Porthos.Dialog('assets').get(content)).select('div.pagination a').invoke('observe', 'click', function(event) {
      this.findAssets(event.element().href);
      event.stop();
    }.bind(this));
  },
  
  observeAsset: function(asset) {
    var proxy = $span({
      'class':'click_proxy',
      'id':'click_proxy_for_' + Porthos.extractId(asset.id)
    });
    asset.appendChild(proxy);
    proxy.observe('click', this.options.callback.bindAsEventListener(this));
    proxy.observe('mouseover', function(event) {
      asset.addClassName('active');
    });
    proxy.observe('mouseout', function(event) {
      asset.removeClassName('active');
    });
  },
  
  positionAssetsMeta: function(parent) {
    $(parent).select('div.meta').each(function(element){
      element.setStyle({
        'right':-element.getDimensions().width+'px'
      });
    });
  },
  
  search: function(event) {
    form = event.element();
    new Ajax.Request(form.action, {
      method:'get',
      parameters:form.serialize(),
      onLoading: function() {
        Porthos.Dialog().setWaitState();
      }.bind(this),
      onComplete: function(response) {
        Porthos.Dialog().clearWaitState();
        Porthos.Dialog('assets').insert('search', response.responseText);
        this.observeSearchBox('search');
        this.observeAssets('search');
        Porthos.SearchField.find(Porthos.Dialog('assets').get('search'));
      }.bind(this)
    });
    event.stop();
  }  
});

Porthos.Assets.IndexView = Class.create({
  initialize: function() {
    if($('view_options')) {
      this.assets_list = $$('ul.assets').first();
      this.setUpUploadObserver($$('#add_files ul li').first());
      this.setUpPerPageObserver();
      this.setUpViewSelectObserver();
    }
  },
  
  setUpPerPageObserver : function (){
    $('assets_per_page').observe('change', function(ev) {
      $('view_options').submit();
    });
  },
  
  setUpViewSelectObserver : function () {
    if(getCookie('assets_view_type') == 'overview'){
      this.assets_list.addClassName('overview');
      $('view_type').selectedIndex = 1;
    }
    
    $('view_type').observe('change', function(ev) {
      var type = $('view_type').value;
      setCookie('assets_view_type', type)
      if(type == 'overview') {
        this.assets_list.addClassName('overview');
      }else{
        this.assets_list.removeClassName('overview');
      }
    }.bind(this));
  },
  
  setUpUploadObserver : function(el) {
    el.childElements('input').invoke('observe', 'change', function(event) {
      if (event.element().value && $$('#add_files .file').last().value != '') { this.createNewField(); }
      event.stop();
    }.bind(this));
  },
  
  createNewField : function() {
    var new_id = parseInt(Porthos.extractId($('add_files').select('ul li label').last().innerHTML))+1;
    var new_row = $('add_files').select('ul').first().appendChild( $li({'id' : 'file_'+new_id}, $label({'class': 'mini'}, 'Fil '+new_id), $input({'type':'file', 'class':'file', 'size': 15, 'id' : 'file_'+new_id, 'name' : 'files[]' }) ) );
    new Effect.Highlight(new_row);
    this.setUpUploadObserver(new_row);
  }
});

Porthos.Assets.EditView = Class.create({
  initialize: function() {
    if($$('.mediaplayer').length > 0){
      var thumbnail_button = $button('Spara ny försättsbild');
      $$('.fileinfo')[0].appendChild(thumbnail_button);
      thumbnail_button.observe('click', function(event){
        var edit_form = $$('#ca form')[0];
        edit_form.appendChild($input({'type':'hidden', 'name':'asset[thumbnail_position]', 'value':Porthos.Assets.EditView.thumbnail_position}));
        edit_form.submit();
        event.stop();
      });
    }
  }
});

Event.onReady(function() {
  var body = $(document.getElementsByTagName('body')[0]);
  if (body.id == 'assets' ){
    if(body.hasClassName('index')){
      var view = new Porthos.Assets.IndexView();
    }else if(body.hasClassName('edit')){
      var view = new Porthos.Assets.EditView();
    }
  }
});

var player;
function playerReady(obj) {
	var id = obj['id'];
	var version = obj['version'];
	var client = obj['client'];
	player = document.getElementById(id);
	player.addModelListener("TIME", "player_stopped");
};

function player_stopped(time){
  Porthos.Assets.EditView.thumbnail_position = time.position;
}