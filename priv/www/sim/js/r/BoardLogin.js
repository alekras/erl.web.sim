'use strict';

class BoardLogin extends React.Component {

	constructor(props) {
		super(props);
		this.state = {userName:'alex', password:'alex'};
	}
	
	handleChange(event) {
		switch (event.target.name) {
			case 'user' :
				this.setState({userName: event.target.value});
				break;
			case 'password' :
				this.setState({password: event.target.value});
				break;
			default:
				break;
		}
//		console.log('Event comes:: ' + event.target.value + ', ' + event.target.name)
	}

	handleSuccess = (json) => {
		console.log('Login is success: ' + JSON.stringify(json));
		if (json.status == 'ok') {
			this.setState({errorMsg:''});
			this.props.onStateChange(true, this.state.userName, this.state.password);
		} else {
			this.props.warnBox.setLayout(
				'warn', 
				'User name or Password are invalid.<br/>Please try again.', 
				this.props.parent.current.getBoundingClientRect()
			);
			this.props.onStateChange(false);
		}
	};

	handleError = (error) => {
		console.log('AJAX error: ' + error);
		this.props.onStateChange(false);
	};

	handleSubmit(event) {
		this.setState({errorMsg:''});
//		console.log('A userName was submitted: >' + this.state.userName + '<');
		if (this.state.userName == '') { // For debug TODO: remove
			this.setState({userName:'alex', password:'alex'});
		}
		RestAPI.loginRequest(this.state, this.handleSuccess, this.handleError);
		event.preventDefault();
	};

	shouldComponentUpdate(nextProps, nextState) {
//		if (this.state.errorMsg !== nextState.errorMsg) {
//			return true;
//		}
		return true;
	}

	render() {
//		console.log('RENDER BoardLogin: ' + JSON.stringify(this.state));
		return e('form', {onSubmit: (e) => this.handleSubmit(e)}, [
			e(
			'table',
			{
				key:1,
				ref:this.parentTable
			}, e('tbody', {key:1}, [
					e('tr', {key:1}, [e(TextInput, {key:1,label:'User name:',onChange:(e)=>this.handleChange(e),inpName:'user',inpType:'text'})]),
					e('tr', {key:2}, [e(TextInput, {key:1,label:'Password:',onChange:(e)=>this.handleChange(e),inpName:'password',inpType:'password'})]),
					e('tr', {key:3}, [
						e('td',{key:1, colSpan:'2', style:{paddingTop:'25px'}, align:'center'},[
							e('button', {
								key:1,
								className:'btn-login button',
								type:'submit'
							}, `LOGIN`)
						])
					])
				])
			)
		])
	}
}