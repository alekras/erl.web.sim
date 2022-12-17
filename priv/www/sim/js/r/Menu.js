/**
 * 
 */
'use strict';

class Menu extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
	
	handleMouseClick(event) {
	}
	
	render() {
		if(this.props.state) {
			return e(React.Fragment, {}, [
				e(MenuItem, {
					key: 1, 
					onMenuClick: this.props.onMenuClick, 
					name:'Contacts',
					active: (this.props.active == 'Contacts'),
					command:'Contacts'
				}),
				e(MenuItem, {
					key: 2, 
					onMenuClick: this.props.onMenuClick, 
					name:'Chat', 
					active: (this.props.active == 'Chat'),
					command:'Chat'
				}),
				e(MenuItem, {
					key: 3, 
					onMenuClick: this.props.onMenuClick, 
					name:'Help', 
					active: (this.props.active == 'Help'),
					command:'Help'
				}),
				e(MenuItem, {
					key: 4, 
					onMenuClick: this.props.onMenuClick, 
					name:'Log Out', 
					active: (this.props.active == 'Logout'),
					command:'Logout'
				})
			]);
		} else {
			return e(React.Fragment, {}, [
				e(MenuItem, {
					key: 1, 
					onMenuClick: this.props.onMenuClick, 
					name:'Login', 
					active: (this.props.active == 'Login'),
					command:'Login'
				}),
				e(MenuItem, {
					key: 2, 
					onMenuClick: this.props.onMenuClick, 
					name:'Register', 
					active: (this.props.active == 'Register'),
					command:'Register'
				}),
				e(MenuItem, {
					key: 3, 
					onMenuClick: this.props.onMenuClick, 
					name:'Help', 
					active: (this.props.active == 'Help'),
					command:'Help'
				}),
				e(MenuItem, {
					key: 4, 
					onMenuClick: () => {}, 
					name:'',
					active: (this.props.active == '')
				})
			]);
		}
	}
}