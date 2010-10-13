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
          'src'   : Routing.display_image_path('c87x87', this.attributes.file_name, this.attributes.extname),
          'alt'   : this.attributes.title,
          'width' : 87,
          'height': 87
        });
      } else {
        img = $img({
          'src'   : Routing.display_image_path('c87x87', this.attributes.file_name, this.attributes.extname),
          'alt'   : this.attributes.title,
          'width' : 84,
          'height': 87
        });
      }
    } else if (this.attributes.type == 'VideoAsset') {
      img = $img({
        'src'   : Routing.display_image_path('c87x87', this.attributes.thumbnail.file_name, this.attributes.thumbnail.extname),
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

Porthos.Assets.Asset.file_types = $A([
  'jpg',
  'jpeg',
  'png',
  'gif',
  'mov',
  'qt',
  'mp4',
  'mpg',
  'avi',
  'flv',
  'mp3',
  'doc',
  'pdf',
  'psd',
  'eps',
  'ai',
  'zip',
  'swf'
]);

Porthos.Assets.Uploader = Class.create({
  initialize: function(form, options) {
    if (typeof SWFUpload == "undefined") { return; }
    if (!(this.form = $(form))) { return; }

    this.queue = $A();
    this.uploaded_files = $A();
    this.bytes_transfered = 0;
    
    var placeholder =  $span({'id' : 'select_files'});
    this.browse_link = $a({ 'id' : 'add_assets_to_queue', 'href' : '#' }, 'Välj filer att ladda upp');
    this.browse_link.observe('click', this.selectFiles.bindAsEventListener(this));
    Element.insert(this.form.parentNode, {
      'top' : $div({
        'id' : 'init_file_dialogue'
      }, $h2({}, placeholder, this.browse_link, ' eller ', $a({
        'class' : 'cancel',
        'href' : Routing.admin_assets_path()
      }, 'avbryt' )), $p({'class' : 'allowed_formats'}, "Du kan ladda upp: bilder (jpg, png, gif), filmer (fla, swf, mov, mp4, mpg, avi), ljud (mp3, wav) samt andra dokument (doc, zip, pdf, eps)."))
    });
    
    this.options = Object.extend({
      upload_url                   : this.form.action,
      flash_url                    : "/javascripts/porthos/swfupload/swfupload.swf",
      post_params                  : {
        "format" : "js"
      },
      use_query_string             : false,
      debug                        : false,
      file_post_name               : "asset[file]",
      file_types                   : Porthos.Assets.Asset.file_types.collect(function(type) { return '*.' + type }).join(';'),
      file_queued_handler          : this.addAsset.bind(this),
      file_dialog_complete_handler : this.dialogComplete.bind(this),
      upload_start_handler         : this.upload.bind(this),
      upload_progress_handler      : this.fileProgress.bind(this),
      upload_success_handler       : this.uploadComplete.bind(this),
      queue_complete_handler       : this.queueComplete.bind(this),
      button_placeholder_id        : "select_files",
      button_width                 : 230,
      button_height                : 28,
      button_window_mode           : SWFUpload.WINDOW_MODE.TRANSPARENT,
      button_cursor                : SWFUpload.CURSOR.HAND
    }, options || {});
            
    this.swfu = new SWFUpload(this.options);
    $('submit_container').hide();
    this.form.select('input[type=file]').invoke('hide');
    this.form.select('input[type=submit]').invoke('observe', 'click', this.submit.bindAsEventListener(this));
  },
  
  countTotalBytes: function() {
    this.bytes_queued = this.queue.inject(0, function(sum, file) {
      return sum + file.size;
    });
    return this.bytes_queued;
  },
  
  selectFiles: function(event) {
    this.swfu.selectFiles();
    event.stop();
  },
  
  submit: function(event) {
    this.swfu.startUpload();
    $('submit_container').hide();
    $('add_assets_to_queue').update('Uploading ...');
    event.stop();
  },
  
  addAsset: function(file) {
    if (this.queue.size() == 0 && !this.queue_element) {
      this.setup();
    }
    this.queue.push(file);
    remove_link = $a({ 'href' : '#', 'class' : 'remove' }, $span({}, 'Remove'));
    remove_link.observe('click', function(event) {
      this.removeAsset(file);
      event.stop();
    }.bind(this));
    Element.insert(this.queue_element, {
      'bottom' : $li({
        'id' : 'file_queue_' + file.id
      }, $span({
        'class' : 'name'
      }, file.name), $span({
        'class' : 'size'
      }, Math.formatBytes(file.size)), $span({
        'class' : 'progress'
      }, remove_link))
    });
  },
  
  removeAsset: function(file) {
    $('file_queue_' + file.id).remove();
    this.removeFromInternalQueue(file);
    this.updateStatus();
    this.swfu.cancelUpload(file.id);
    if (this.queue.size() == 0) {
      this.tearDown();
    }
  },
  
  upload: function(file) {
    $('file_queue_'+file.id).addClassName('uploading');
  },
  
  fileProgress: function(file, bytes_loaded, bytes_total) {
    var percentage = Math.ceil((bytes_loaded / bytes_total) * 100);
    $('file_queue_' + file.id).select('span.progress').first().update(percentage + '%');
  },
  
  updateTotalProgress: function(file) {
    this.bytes_transfered += file.size;
    var percentage = Math.ceil((this.bytes_transfered / this.bytes_queued) * 100);
    $('total_progress').update(percentage + '%');
  },
  
  dialogComplete: function() {
    if (this.queue.size() > 0) {
      this.updateStatus();
    }
  },
  
  uploadComplete: function(file, response) {
    this.uploaded_files.push(response.evalJSON().first());
    $('file_queue_' + file.id).addClassName('complete').removeClassName('uploading');
    $('file_queue_' + file.id).select('span.progress').first().update('100%');
    this.removeFromInternalQueue(file);
    this.updateTotalProgress(file);
    return true;
  },
  
  queueComplete: function(num_files_uploaded) {
    asset_params = this.uploaded_files.collect(function(f){
      return 'assets[]='+f.id;
    }).join('&');
    $('add_assets_to_queue').update('Alla filer är uppladdade!').addClassName('upload_complete');
    view_new_assets_link = $a({ 'href' : Routing.incomplete_admin_assets_path()+'?'+asset_params }, 'Beskriv och sätt nyckelord på filerna')
    Element.insert(this.form, {
      'before' : $p({
        'class' : 'next_steps'
      }, view_new_assets_link, ' eller ', $a({ 'href' : Routing.new_admin_asset_path() }, 'ladda upp fler'))
    });
  },
  
  updateStatus: function() {
    $('total_size').update(Math.formatBytes(this.countTotalBytes()));
  },
  
  setup: function() {
    this.queue_container = $div();
    this.queue_element = $ul({ 'class' : 'files' });
    Element.insert(this.queue_container, {
      'top' : this.queue_element
    });
    this.browse_link.old_text = this.browse_link.innerHTML;
    this.browse_link.update('Lägg till fler filer');
    var totals = $div({
      'class' : 'totals'
    }, $span({
      'id' : 'total_size',
      'class' : 'size total'
    }), $span({
      'id'    : 'total_progress',
      'class' : 'progress total'
    }));
    Element.insert(this.form, { 'top' : this.queue_container });
    Element.insert(this.queue_element, {
      'after' : totals
    });
    $('submit_container').show();
  },
  
  tearDown: function() {
    this.queue = $A();
    Element.remove(this.queue_container);
    this.queue_container = null;
    this.queue_element = null;
    this.browse_link.update(this.browse_link.old_text);
    $('submit_container').hide();
  },
  
  removeFromInternalQueue: function(file) {
    this.queue = this.queue.reject(function(queued_file) {
      return queued_file.id == file.id;
    });
  }
});


Porthos.Assets.IframeUploader = Class.create({
  initialize: function(form, options) {
    if (!(this.form = $(form))) { return; }
    this.form.action += '.json';
    this.options = Object.extend({
      timer: 0.5
    }, options || {});
    this.onLoading  = options.onLoading || Prototype.emptyFunction;
    this.onComplete = function(element, value) {
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
    new Ajax.Request(url || Routing.admin_assets_path()+'?type='+this.assets_type+'&per_page=24', {
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
        new Porthos.Assets.IframeUploader('upload_asset_form', {
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
              new Ajax.Request(Routing.edit_admin_asset_path({'id': new_asset.attributes.file_name}, 'js'), {
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
      this.setUpPerPageObserver();
      this.setUpViewSelectObserver();
    }
    new Porthos.TagAutoCompletion($('search_query'));
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
  }
});

Porthos.Assets.EditView = Class.create({
  initialize: function() {
    if($$('.VideoAsset').length > 0 && $(document.getElementsByTagName('body')[0]).hasClassName('edit')){
      var thumbnail_button = $button('Spara ny försättsbild');
      $$('.asset')[0].appendChild(thumbnail_button);
      thumbnail_button.observe('click', function(event){
        var edit_form = $$('#c_2 form')[0];
        edit_form.appendChild($input({'type':'hidden', 'name':'asset[thumbnail_position]', 'value':Porthos.Assets.EditView.thumbnail_position}));
        edit_form.submit();
        event.stop();
      });
    }
    $$('input.asset_tags').each(function(element) {
      new Porthos.TagAutoCompletion(element);
    });
  }
});

Porthos.Assets.NewView = Class.create({
  initialize: function() {
    new Porthos.Assets.Uploader('upload', { debug: false });
  }
});

document.observe('dom:loaded', function() {
  $$('#filters_order_by_submit').invoke('hide');
  $$('#filters_order_by').invoke('observe', 'change', function(event) {
    this.form.submit();
  });

  var body = $(document.getElementsByTagName('body')[0]);
  if (body.id == 'assets_view' ){
    if (body.hasClassName('index')){
      var view = new Porthos.Assets.IndexView();
    } else if (body.hasClassName('edit') || body.hasClassName('incomplete')){
      var view = new Porthos.Assets.EditView();
    } else if (body.hasClassName('new')){
      var view = new Porthos.Assets.NewView();
    }
  }
});

var player;
function playerReady(obj) {
  var id = obj.id;
  var version = obj['version'];
  var client = obj['client'];
  player = document.getElementById(id);
  player.addModelListener("TIME", "player_stopped");
};

function player_stopped(time){
  Porthos.Assets.EditView.thumbnail_position = time.position;
}