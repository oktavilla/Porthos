var Money = Class.create();
Money.regExp = new RegExp(/(\-?\d+(\.(\d+))?)/);
Money.prototype = {
  initialize: function(cents) {
    this.cents = cents || 0;
  },
  format: function(options) {
    return this.toString(options || {});
  },
  toString: function(options) {
    options = Object.extend({
      no_cents: false
    }, options || {});
    // boy it sure would be nice if javascript had sprintf
    var s = (this.cents / 100).toString();
    if (!options.no_cents) {
      var p = s.indexOf('.');
      if(p > -1) {
        var n = 3 - (s.length - p);
        for(var i = 0; i < n; i++) {
          s = s + '0';
        }
      } else {
        s = s + '.00';
      }
    }
    return s;
  },
  toMoney: function() {
    return this;
  }
}

Number.prototype.toMoney = function() {
  return new Money(this * 100);
}

String.prototype.toMoney = function() {
  var matches = Money.regExp.exec(this);
  return new Money(matches ? Number(matches[0]) * 100 : 0);
}

function setCookie(c_name,value,expiredays)
{
  var exdate = new Date();
  exdate.setDate(exdate.getDate()+expiredays);
  document.cookie = c_name+ "=" +escape(value)+((expiredays==null) ? "" : ";expires="+exdate.toGMTString());
}

function getCookie(c_name)
{
  if(document.cookie.length > 0) {
    c_start=document.cookie.indexOf(c_name + "=");
    if (c_start!=-1) { 
      c_start=c_start + c_name.length+1; 
      c_end=document.cookie.indexOf(";",c_start);
      if (c_end==-1) c_end=document.cookie.length;
      return unescape(document.cookie.substring(c_start,c_end));
    } 
  }
  return "";
}