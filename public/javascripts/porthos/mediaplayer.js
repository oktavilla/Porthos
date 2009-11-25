if(typeof(Prototype) != 'undefined') {
  Event.onReady(setup_players);
}else if(typeof(jQuery) != 'undefined'){
  $(document).ready(setup_players);
}else if(typeof(DOMAssistant) != 'undefined'){
  DOMAssistant.DOMReady(setup_players); 
}

function setup_players(){
  players = getElementsByClassName(document, "div", "mediaplayer");
  for(var i=0; i<players.length; i++){
    create_player(players[i]);
	}
}

function create_player(el) {
  var options = {
    'width' : 320,
    'height' : 260
  };  
  
  el.getElementsByTagName("a")[0].style.display = 'none';    
  option_tags = el.getElementsByTagName("span");
  for(var i=0; i<option_tags.length; i++){
    options[option_tags[i].className] = option_tags[i].innerHTML;
  }
  options['id'] = el.id;
  swfobject.embedSWF("/swf/mediaplayer.swf", el.id, options['width'], options['height'], '7', "", options, {"allowfullscreen":"true"});
}

/*
	Written by Jonathan Snook, http://www.snook.ca/jonathan
	Add-ons by Robert Nyman, http://www.robertnyman.com
*/

function getElementsByClassName(oElm, strTagName, strClassName){
	var arrElements = (strTagName == "*" && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);
	var arrReturnElements = new Array();
	strClassName = strClassName.replace(/\-/g, "\\-");
	var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
	var oElement;
	for(var i=0; i<arrElements.length; i++){
		oElement = arrElements[i];
		if(oRegExp.test(oElement.className)){
			arrReturnElements.push(oElement);
		}
	}
	return (arrReturnElements)
}