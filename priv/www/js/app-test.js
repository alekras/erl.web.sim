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
		w = Math.floor(wo/4);
		h = Math.floor(ho/4);
	}
	w = w;
	h = h;
	console.log(">> start. is Mobile=" + ismobile
		+ "; h=" + h + "(" + ho + ")"
		+ "; w=" + w + "(" + wo + ")"
		+ "; index= " + index);
	ReactDOM.render(e(Test, {h:h, w:w}), document.getElementById('main'));
}

function changeLayout(description){
	var href;
	if (description == "mobile") {
		href = "/sim/css/sim-mob-r.css";
	} else {
		href = "/sim/css/sim-r.css";
	}
	document.getElementById("link").setAttribute("href", href);
}

const Test = ({h, w}) => {
	return e('table',
		{
			style:
			{
				margin:'50px auto 50px auto',
				width:w + 'px', height:h + 'px', maxHeight:h+'px'}
		},
		e('tbody', {}, [
			e('tr', {key:1, align:'center', style:{}}, [
				e('td', 
					{
						key:1, 
						style:
						{
							maxHeight:'100%',
							border:'3px solid green'
					}}, 
					e('div', 
						{
							key:1,
							style:{
							display: 'flex',
							flexWrap: 'nowrap',
							flexDirection: 'column',
							overflowY: 'scroll',
							overflowX: 'hidden',
							height:'100%', // (h-6)+'px'
							minHeight: '0'
//								overflow:'auto' 
							}
						}, [
						e('div', 
							{
								key:1,
								style:{
									flexShrink: '0',
									border:'3px solid red',
									backgroundColor: 'grey',
									width:'50px',height:'200px',minHeight:'0'
								}
							}
						),
						e('div', 
							{
								key:2,
								style:
								{
									flexShrink: '0',
									border:'3px solid red',
									backgroundColor: 'grey',
									width:'50px',height:'200px',minHeight:'0'
								}
							}
						)
					])
				)
			])
		])
	);
}