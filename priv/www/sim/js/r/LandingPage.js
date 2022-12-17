'use strict';

class LandingPage extends React.Component {

	constructor(props) {
		super(props);
		this.state = {};
	}

	render() {
		return e(
			'span',
			{
				style:{color:'#3e7878', font:'18pt bold'}
			},
			`Landing page`
		)
	}
}