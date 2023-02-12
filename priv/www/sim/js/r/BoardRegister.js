/**
 * 
 */
'use strict';

class BoardRegister extends React.Component {
	constructor(props) {
		super(props);
		this.state = {userName:'',password1:'',password2:'', errorMsg:''};
	}

	handleChange(event) {
		switch (event.target.name) {
			case 'user' :
				this.setState({userName: event.target.value});
				break;
			case 'password1' :
				this.setState({password1: event.target.value});
				break;
			case 'password2' :
				this.setState({password2: event.target.value});
				break;
			default:
				break;
		}
//		console.log('Event comes:: ' + event.target.value + ', ' + event.target.name)
	}

	handleSuccess = (json) => {
		console.log('Success: ' + JSON.stringify(json));
		if (json.status == 'ok') {
			this.props.warnBox.setLayout(
				'warn', 
				'User "' + this.state.userName + '" is successfully registered.', 
				this.props.parent.current.getBoundingClientRect()
			);
			this.props.onStateChange(true);
			// TODO: You are successfully registered
		} else if (json.reason == 'password') {
			this.props.warnBox.setLayout(
				'warn', 
				'Password is too short or does not fit confirmed one.<br/>Please try again.', 
				this.props.parent.current.getBoundingClientRect()
			);
//			this.setState({errorMsg:'Password is too short or does not fit confirmed one.<br/>Please try again.'});
			this.props.onStateChange(false);
		} else if (json.reason == 'exist') {
//			this.setState({errorMsg:'This user name already exists.<br/>Please try another.'});
			this.props.warnBox.setLayout(
				'warn', 
				'This user name already exists.<br/>Please try another.', 
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
		// TODO: block submit until API call is finished
		console.log('A userName was submitted: ' + this.state.userName);
		RestAPI.registerRequest(this.state, this.handleSuccess, this.handleError);
		event.preventDefault();
	}
	
	handleSubmitByKey(event) {
		if (event.code == 'Enter') {
//			console.log('onSubmit event: >' + event.code + '<');
			RestAPI.registerRequest(this.state, this.handleSuccess, this.handleError);
		}
	};

	render() {
		return e('form', 
				{
					onSubmit: (e) => this.handleSubmit(e),
					onKeyDown: (e) => this.handleSubmitByKey(e)
				}, [
			e(
			'table',
			{
				key:1
			}, [
				e('tbody', {key:1}, [
					e('tr', {key:1}, [e(TextInput, {key:1,label:'User name:',onChange:(e)=>this.handleChange(e),inpName:'user',inpType:'text'})]),
					e('tr', {key:2}, [e(TextInput, {key:1,label:'Password:',onChange:(e)=>this.handleChange(e), inpName:'password1',inpType:'password'})]),
					e('tr', {key:3}, [e(TextInput, {key:1,label:'Password confirm:',onChange:(e)=>this.handleChange(e), inpName:'password2',inpType:'password'})]),
					e('tr', {key:4}, [
						e('td',{key:1, colSpan:'2', style:{paddingTop:'25px'}, align:'center'},[
							e('button', {
								key:1,
								className:'button btn-register',
								type:'submit',
								}, `REGISTER`)
						])
					])
				])
			])
		])
	}
}