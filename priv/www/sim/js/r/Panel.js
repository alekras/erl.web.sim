'use strict';

class Panel extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			activeMenu: 'Land',
			board: 'Land',
			user: undefined,
			pw: undefined,
			connected:false,
			connectedTo:'',
			auth:false
		};
	}
	
	handleMouseClickMenu(event, command) {
		console.log('Click on ' + command);
		if (command == 'Logout') {
			if (BoardChat.mqttClient) {
				BoardChat.mqttClient.disconnect();
				delete BoardChat.mqttClient;
			}
			BoardChat.messageList = [];
			this.setState({
				auth:false,
				activeMenu:'Land',
				board:'Land',
				user:undefined
			});
		} else {
			this.setState({activeMenu: command, connectedTo:this.state.user});
		}
	}
	
	handleStateChange = (auth, un, pw) => {
//		console.log('State change: ' + JSON.stringify(this.state) 
//				+ ' auth: ' + auth + ' un: ' + un + ' pw: ' + pw);
		if (auth) {
			this.createMQTTClient(un, pw);
//			BoardChat.mqttClient.connect();
			this.setState({
				auth:true,
				activeMenu:'Contacts',
				board:'Contacts',
				user: un,
				pw: pw
			});
		} else {
			if (BoardChat.mqttClient) {
				BoardChat.mqttClient.disconnect();
				delete BoardChat.mqttClient;
			}
			this.setState({
				auth:false,
				activeMenu:'Login',
				board:'Login',
				user: undefined,
				pw: undefined
			});
		};
	}
	
	createMQTTClient = (userName, password) => {
		if (!BoardChat.mqttClient) {
			BoardChat.mqttClient = new MQTTClient({
				host: Config.mqtt_host,
				port: Config.mqtt_port,
				ssl: Config.mqtt_ssl,
				user: userName,
				password: password
			});
		}
		BoardChat.mqttClient.afterMsgArrive = () => {};
	}
	
	handleStateChangeReg = (success) => {
//		console.log('State change Reg: ' + JSON.stringify(this.state));
		if (success) {
			this.setState({
				auth:false,
				activeMenu:'Login',
				board:'Login'
			});
		} else {
			this.setState({
				auth:false,
				activeMenu:'Register',
				board:'Register'
			});
		};
	}

	handleMoveToChat = (e, contact) => {
		this.setState({
			connectedTo:contact,
			activeMenu:'Chat',
			board:'Chat'
		});
	}

	render() {
		var board;
		switch (this.state.activeMenu) {
			case 'Login' :
				board = e(BoardLogin, {key:1, onStateChange:this.handleStateChange}, null);
				break;
			case 'Register' :
				board = e(BoardRegister, {key:1, onStateChange:this.handleStateChangeReg}, null);
				break;
			case 'Help' :
				board = e(BoardHelp, {key:1});
				break;
			case 'Contacts' :
				board = e(BoardContacts, {key:1, onMoveToChat:this.handleMoveToChat, user:this.state.user}, null);
				break;
			case 'Chat' :
				board = e(BoardChat, 
						{	key: 1, 
							user:this.state.user, 
							password:this.state.pw, 
							contact:this.state.connectedTo,
							w:this.props.w,
							h:this.props.h
						},
						null);
				break;
			case 'Logout' :
				board = e(LandingPage, {key: 1}, null);
				break;
			default : 
				board = e(LandingPage, {key: 1}, null);
				break;
		}
		return e('table', {className:'table', style:{width:this.props.w, height:this.props.h}},
			e('tbody', {}, [
				e('tr', {align:"center", key: 1}, [
					e('td', {key: 1, colSpan:'4', className:'title'}, [
						e(Title, {key: 1, user:this.state.user})
					])
				]),
				e('tr', {align:"center", className:'menu', key: 2}, [
					e(Menu, {key: 1,
						onMenuClick:(event, command) => this.handleMouseClickMenu(event, command),
						state: this.state.auth,
						active: this.state.activeMenu
					})
				]),
				e('tr', {align:"center", key: 3}, [
					e('td', {key: 1, className:'board-container', colSpan:'4'}, [
						board
					])
				]),
				e('tr', {key: 4}, [
					e('td', {key: 1, colSpan:'4', style:{height: '10px'}}, [
						e('div',
							{
								id: 'copyright',
								className: 'copyright',
								key: 1
							},
							`©AKrasnopolski 2022 v 0.0.2 (React)`
						)
					])
				])
			]
		))
	}
}