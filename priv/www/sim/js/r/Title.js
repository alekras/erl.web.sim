/**
 * 
 */
'use strict';

class Title extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
	
	handleMouseClick(event) {
	}
	
	render() {
		var title = 'SLICK INSTANT MESSENGER (SIM)';
		var user = ((this.props.user)? ('User: ' + this.props.user) : '');
		var bgColor;
		if (this.props.connected) {
			bgColor = 'Aquamarine';
		} else {
			bgColor = 'LightSalmon';
		}
		return e(React.Fragment, {}, [
			e('span',
				{key:0, className: 'ssl-seal'}
			),
			e('span',
				{key:1, style:{color:'#3e7878', margin:'5px 2px 0 2px', float:'left'}},
				title
			),
			e('span',
				{key:2, style:{color:'#3e7878', margin:'5px 2px 0 2px', backgroundColor:bgColor, float:'right'}}, 
				user
			),
			e('span', {key:3, style:{clear:'both'}})
		]);
	}
}