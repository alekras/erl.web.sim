'use strict';
const e = React.createElement;

var index = 0;

function start() {
	let ismobile = (navigator.userAgent.match(/(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i)) ? true : false;
	let wo = window.innerWidth, 
		ho = window.innerHeight;
	let w, h;
	if (ismobile) {
		changeLayout('mobile', index);
		w = wo;
		h = ho;
	} else {
		changeLayout('default', index);
		w = Math.floor(wo/2);
		h = Math.floor(ho * 0.8);
	}
	w = w + 'px';
	h = h + 'px';
	console.log(">> start. is Mobile=" + ismobile
		+ "; h=" + h + "(" + ho + ")"
		+ "; w=" + w + "(" + wo + ")"
		+ "; index= " + index);
	ReactDOM.render(e(Panel, {h:h, w:w}), document.getElementById('main'));
}
/*
function changeLayout(description, index){
	if (index) {
		index = index % 2;
	} else {
		index = 0;
	}
	var a = document.getElementById("link");
	if (description == "mobile") {
		a.setAttribute("href", "/game/css/game-mob-" + index + ".css");
	} else {
		a.setAttribute("href", "/game/css/game-" + index + ".css");
	}
}
*/
function changeLayout(description){
	var href;
	if (description == "mobile") {
		href = "/sim/css/sim-mob-r.css";
	} else {
		href = "/sim/css/sim-r.css";
	}
	document.getElementById("link").setAttribute("href", href);
}
/*
function doOnLoad(restore) {
//	new Button($('table-row-2'), board);
	if (restore) {
		new Ajax.Request('/game/restoregame',{
			method: 'get',
			requestHeaders: {Accept: 'application/json'},
			onSuccess: 
				function(transport){
					var json = transport.responseText.evalJSON(true);
//		console.log("receive: " + json.white[0] + ";" + json.black[1]);
					board.clean_board();
					board.set_position(json);
			}
		});

	}
}
*/