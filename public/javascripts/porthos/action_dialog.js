/**
** ActionDialog
** Simple show / hide dialog box that takes arbitary content.
**/
Porthos.namespace('Porthos.ActionDialog');
Porthos.ActionDialog.sessions = {
  _sessions: $H(),

  history  : $A(),

  _each: function(iterator) {
    this._sessions._each(iterator);
  },
  
  include: function(value) {
    return this._sessions.include(value);
  },
  
  get: function(name) {
    return this._sessions.get(name);
  },
  
  getOrCreate: function(name) {
    if (!(session = this.get(name))) {
      session = new Porthos.ActionDialog.Session(name);
      this._sessions.set(name, session);
    }
    return session;
  },
  
  clear: function() {
    this._sessions.values().invoke('remove');
    this._sessions = $H();
    this.history   = $A();
  }
};
Object.extend(Porthos.ActionDialog.sessions, Enumerable);

Porthos.ActionDialog.Session = Class.create({
  initialize: function(name) {
    this.contents = $H();
    this.history  = $A();
    this.number   = Porthos._dialog.sessions.size();
  },
  
  insert: function(name, content) {
    this.hide();
    if (!this.contents.get(name)) {
      this.contents.set(name, 'action_dialog_session_' + this.number + '_contents_' + name);
      Porthos.Dialog().element.appendChild($div({
        'id'    :  this.contents.get(name),
        'class' : 'dialog_content',
        'style' : 'display:none'
      }));
      $(this.contents.get(name)).insert(content, { position: 'top' });
    } else {
      $(this.contents.get(name)).innerHTML = content;
    }
    this.show(name);
    $(this.contents.get(name)).select('a.back, a.cancel').invoke('observe', 'click', function(event) {
      this.historyBack();
      event.stop();
    }.bind(this));
  },
  
  get: function(name) {
    return $(this.contents.get(name));
  },
  
  show: function(name) {
    Porthos.Dialog().sessions.findAll(function(session) {
      return session[1] != this;
    }.bind(this)).collect(function(session) {
      return session[1];
    }).invoke('hide');
    if (name) {
      this.get(name).show();
      if (this.history.last() != name) {
        this.history.push(name);
      }
    } else {
      this.get(this.history.last()).show();
    }
    if ((Porthos._dialog.sessions.history.last() && Porthos._dialog.sessions.history.last().number != this.number) || Porthos._dialog.sessions.history.size() == 0) {
      Porthos._dialog.sessions.history.push(this);
    }
    Porthos.Dialog().expandBackground();
    $('action_dialog_container').scrollTo();
  },

  hide: function() {
    this.contents.each(function(name) {
      $(name[1]).hide();
    });
  },
  
  remove: function() {
    this.contents.each(function(name) {
      $(name[1]).remove();
    });
  },
  
  
  historyBack: function() {
    if (this.history.size() > 1) {
      this.hide();
      this.history.pop();
      this.get(this.history.last()).show();
    } else {
      Porthos.Dialog().historyBack();
    }
  }

});

Porthos.ActionDialog.Dialog = Class.create({
  initialize: function() {
    this.sessions = Porthos.ActionDialog.sessions;
    this.element = this.createElement();
  },
  
  show: function() {
    $(this.container_id).style.top = (document.viewport.getScrollOffsets().top)+'px';
    new Effect.Appear(this.background_id, {
      duration: 0.2,
      to: 0.8,
      queue: { scope: 'dialogs' },
      afterFinish: function() {
        $(this.container_id).show();
      }.bind(this)
    });
  },
  
  hide: function() {
    new Effect.Fade(this.background_id, {
      duration: 0.1,
      queue: { scope: 'dialogs' },
      afterFinish: function() {
        $(this.container_id).hide();
        this.sessions.clear();
      }.bind(this)
    });
  },
  
  setWaitState: function() {
    $(this.container_id).appendChild($span({
        'class': 'load_notice'
      },
      $img({
        'src': '/graphics/porthos/icons/processing_anim_big.gif',
        'alt': 'Laddar ..'
      })
    ));
  },
  
  clearWaitState: function() {
    $(this.container_id).getElementsBySelector('span.load_notice').invoke('remove');
  },
  
  current: function() {
    return this.sessions.history.last() || false;
  },
  
  switchTo: function(name) {
    this.sessions.findAll(function(session) {
      return session[0] != name;
    }).collect(function(session) {
      return session[1];
    }).invoke('hide');
    this.sessions.get(name).show();
  },
  
  historyBack: function() {
    if (this.sessions.history.size() > 1) {
      this.current().hide();
      this.sessions.history.pop();
      this.current().show();
    } else {
      this.hide();
    }
  },
  
  createElement: function() {
    this.background_id = 'action_dialog_background';
    this.container_id  = 'action_dialog_container';
    
    $$('body')[0].appendChild($div({
      'id'   :  this.background_id,
      'class': 'action_dialog_background',
      'style': 'display:none'
    }));
    
    main_cancel = $a({
      'id'    : 'main_cancel',
      'class' : 'cancel',
      'href'  : window.location
    }, 'Cancel');
    
    $$('body')[0].appendChild($div({
      'id'   :  this.container_id,
      'class': 'action_dialog_container',
      'style': 'display:none'
    }, main_cancel));
    
    this.expandBackground();

    main_cancel.observe('click', function(event) {
      this.hide();
      event.stop();
    }.bind(this));
    return $(this.container_id);
  },
  
  expandBackground: function() {
    viewport = document.viewport.getHeight();
    body     = $(document.getElementsByTagName('body')[0]).getHeight();
    height   = (body > viewport) ? body : viewport;
    $(this.background_id).style.height = height + 'px';
  }
});

Porthos._dialog = new Porthos.ActionDialog.Dialog();

Porthos.Dialog = function(name) {
  return name ? Porthos._dialog.sessions.getOrCreate(name) : Porthos._dialog;
}

Event.observe(window, "unload", function() {
  Porthos._dialog = null;
});