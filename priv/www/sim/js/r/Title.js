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
		var title = 'SIMPLE INSTANT MESSENGER (SIM)';
		var user = ((this.props.user)? ('User: ' + this.props.user) : '');
		var bgColor;
		if (this.props.connected) {
			bgColor = 'Aquamarine';
		} else {
			bgColor = 'LightSalmon';
		}
		return e(React.Fragment, {}, [
			e('span',
				{key:0, style:{color:'#3e7878', float:'left'}},
				title
			),
			e('span',
				{key:1, style:{color:'#3e7878', backgroundColor:bgColor, float:'right'}}, 
				user
			),
			e('span', {key:2, style:{clear:'both'}})
		]);
	}
}